"""Stdio proxy in front of JetBrains kotlin-lsp.

kotlin-lsp points navigation targets at entries inside source archives
(`jar:///…/foo-sources.jar!/pkg/Foo.kt`), which Zed cannot open
(zed-extensions/kotlin#106). Every message is forwarded untouched, except
responses to location requests: archive entries are extracted to a cache
directory and their URIs rewritten to plain `file://` ones.

Usage: kotlin-lsp-proxy <kotlin-lsp> [args...]
"""

import hashlib
import json
import os
import re
import signal
import subprocess
import sys
import tempfile
import threading
import zipfile
from pathlib import Path, PurePosixPath
from urllib.parse import unquote

LOCATION_METHODS = {
    "textDocument/definition",
    "textDocument/typeDefinition",
    "textDocument/implementation",
    "textDocument/declaration",
    "textDocument/references",
}
ARCHIVE_URI = re.compile(
    r"^[a-z][a-z0-9+.-]*:(?:file:)?/*(.*?\.(?:jar|zip))!/(.+)$", re.I
)
CACHE_DIR = (
    Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache")
    / "kotlin-lsp-sources"
)


def read_message(stream):
    """Returns (raw bytes, body bytes) of the next message, or None on EOF."""
    header = b""
    length = None
    while True:
        line = stream.readline()
        if not line:
            return None
        header += line
        if line in (b"\r\n", b"\n"):
            break
        name, _, value = line.partition(b":")
        if name.strip().lower() == b"content-length":
            length = int(value)
    if length is None:
        return None
    body = stream.read(length)
    if len(body) < length:
        return None
    return header + body, body


def frame(message):
    body = json.dumps(message, separators=(",", ":")).encode()
    return b"Content-Length: %d\r\n\r\n" % len(body) + body


def extract(uri):
    """Extracts the archive entry `uri` points at; returns its file:// URI."""
    match = ARCHIVE_URI.match(uri)
    if not match:
        return None
    archive = Path("/" + unquote(match[1]))
    entry = PurePosixPath(unquote(match[2]))
    if entry.is_absolute() or ".." in entry.parts:
        return None

    # Gradle and Nix both put the content hash into the archive path, so the
    # path alone identifies the archive's contents.
    digest = hashlib.sha256(str(archive).encode()).hexdigest()[:12]
    target = CACHE_DIR / f"{archive.stem}-{digest}" / entry
    if not target.exists():
        try:
            with zipfile.ZipFile(archive) as jar:
                content = jar.read(str(entry))
            target.parent.mkdir(parents=True, exist_ok=True)
            fd, tmp = tempfile.mkstemp(dir=target.parent)
            with os.fdopen(fd, "wb") as out:
                out.write(content)
            # Read-only: edits to an extracted copy would go nowhere.
            os.chmod(tmp, 0o444)
            os.replace(tmp, target)
        except (OSError, KeyError, zipfile.BadZipFile):
            return None
    return target.as_uri()


def rewrite(node):
    """Rewrites archive URIs of Location/LocationLink items in place."""
    changed = False
    if isinstance(node, list):
        for item in node:
            changed |= rewrite(item)
    elif isinstance(node, dict):
        for key in ("uri", "targetUri"):
            value = node.get(key)
            if isinstance(value, str):
                extracted = extract(value)
                if extracted:
                    node[key] = extracted
                    changed = True
    return changed


def main():
    if len(sys.argv) < 2:
        sys.exit("Usage: kotlin-lsp-proxy <kotlin-lsp> [args...]")

    server = subprocess.Popen(
        sys.argv[1:], stdin=subprocess.PIPE, stdout=subprocess.PIPE
    )
    for sig in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP):
        signal.signal(sig, lambda *_: server.terminate())

    # Ids of in-flight requests whose responses carry locations.
    pending = set()
    lock = threading.Lock()

    def client_to_server():
        try:
            while message := read_message(sys.stdin.buffer):
                raw, body = message
                if b'"id"' in body and b'"textDocument/' in body:
                    request = json.loads(body)
                    if request.get("method") in LOCATION_METHODS:
                        with lock:
                            pending.add(request.get("id"))
                server.stdin.write(raw)
                server.stdin.flush()
        except (OSError, ValueError):
            pass
        finally:
            # Zed went away: let the server see EOF, then make sure it exits.
            try:
                server.stdin.close()
            except OSError:
                pass
            try:
                server.wait(timeout=5)
            except subprocess.TimeoutExpired:
                server.terminate()

    threading.Thread(target=client_to_server, daemon=True).start()

    out = sys.stdout.buffer
    try:
        while message := read_message(server.stdout):
            raw, body = message
            if pending and b'"id"' in body:
                try:
                    response = json.loads(body)
                except ValueError:
                    response = {}
                # The server numbers its own requests independently, so only
                # a message without a method answers one of ours.
                if "method" not in response:
                    with lock:
                        tracked = response.get("id") in pending
                        pending.discard(response.get("id"))
                    if tracked and rewrite(response.get("result")):
                        raw = frame(response)
            out.write(raw)
            out.flush()
    except OSError:
        server.terminate()
    sys.exit(server.wait())


if __name__ == "__main__":
    main()
