final: _prev: {
  kotlin-lsp = final.stdenvNoCC.mkDerivation (
    finalAttrs:
    let
      inherit (final.stdenvNoCC.hostPlatform) isLinux;

      dist = "https://download.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}";

      sources = {
        aarch64-darwin = {
          url = "${dist}-aarch64.sit";
          hash = "sha256-tAO/ilS9RY47pnMc+KuzNAvgi0OcA1dt/AKxP682lLg=";
        };
        x86_64-linux = {
          url = "${dist}.tar.gz";
          hash = "sha256-rgxLAeF6tzpKUienjqmebcvj5JlgAxWyJ1mk5M3dEd8=";
        };
      };
    in
    {
      pname = "kotlin-lsp";
      version = "263.7084.0";

      src = final.fetchurl sources.${final.stdenvNoCC.hostPlatform.system};

      nativeBuildInputs = [
        final.makeBinaryWrapper
      ]
      ++ (if isLinux then [ final.autoPatchelfHook ] else [ final.unzip ]);

      # The launcher and the bundled JBR are linked against FHS paths
      buildInputs = final.lib.optionals isLinux [
        final.stdenv.cc.cc.lib
        final.zlib
      ];

      # AWT and sound libraries of the JBR are never loaded by a headless server
      autoPatchelfIgnoreMissingDeps = isLinux;

      unpackPhase = if isLinux then "tar -xzf $src" else "unzip -q $src";
      sourceRoot = "kotlin-server-${finalAttrs.version}";

      # On darwin the bundle ships a signed JBR
      dontFixup = !isLinux;
      dontStrip = true;

      installPhase = ''
        mkdir -p $out/share
        cp -R . $out/share/kotlin-lsp
        makeWrapper $out/share/kotlin-lsp/bin/intellij-server $out/bin/kotlin-lsp
      '';

      meta = {
        mainProgram = "kotlin-lsp";
        platforms = builtins.attrNames sources;
      };
    }
  );
}
