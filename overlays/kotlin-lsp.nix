final: _prev: {
  kotlin-lsp = final.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "kotlin-lsp";
    version = "263.7084.0";

    src = final.fetchurl {
      url = "https://download.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}-aarch64.sit";
      hash = "sha256-tAO/ilS9RY47pnMc+KuzNAvgi0OcA1dt/AKxP682lLg=";
    };

    nativeBuildInputs = [
      final.unzip
      final.makeBinaryWrapper
    ];

    unpackPhase = "unzip -q $src";
    sourceRoot = "kotlin-server-${finalAttrs.version}";

    # The bundle ships a signed JBR; fixup would strip it and break the signature.
    dontFixup = true;

    installPhase = ''
      mkdir -p $out/share
      cp -R . $out/share/kotlin-lsp
      makeWrapper $out/share/kotlin-lsp/bin/intellij-server $out/bin/kotlin-lsp
    '';

    meta = {
      mainProgram = "kotlin-lsp";
      platforms = [ "aarch64-darwin" ];
    };
  });
}
