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

    vendorHash = null;

    meta = {
      mainProgram = "yknotify";
      platforms = final.lib.platforms.darwin;
    };
  };
}
