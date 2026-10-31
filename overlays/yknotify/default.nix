final: _prev: {
  yknotify = final.buildGoModule {
    pname = "yknotify";
    version = "0-unstable-2026-03-24";

    src = final.fetchFromGitHub {
      owner = "noperator";
      repo = "yknotify";
      rev = "0c773bdadedb137d02d95c79430fa5e0442c9950";
      hash = "sha256-AhTr3lzYS6z1XoqVC2IIdJoDVdWajrbGhOe20dVQrGQ=";
    };

    # Upstream treats any USB HID device opened via IOHIDLibUserClient as a
    # security key, so touchscreens and other HID readers trigger FIDO2 alerts.
    # Only count devices on the FIDO HID usage page (0xF1D0).
    patches = [ ./fido-only.patch ];

    vendorHash = null;

    meta = {
      mainProgram = "yknotify";
      platforms = final.lib.platforms.darwin;
    };
  };
}
