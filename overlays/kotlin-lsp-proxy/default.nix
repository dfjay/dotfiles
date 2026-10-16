final: _prev: {
  # Makes library sources inside jars openable in Zed (zed-extensions/kotlin#106).
  kotlin-lsp-proxy = final.writers.writePython3Bin "kotlin-lsp-proxy" { } (
    builtins.readFile ./proxy.py
  );
}
