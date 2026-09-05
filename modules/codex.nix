{
  homeModule =
    {
      pkgs,
      config,
      lib,
      ...
    }:

    let
      configFile = "${config.home.homeDirectory}/.codex/config.toml";
      generated = config.home.file.".codex/config.toml".source;

      mergeConfig =
        pkgs.writers.writePython3 "codex-merge-config"
          {
            libraries = [ pkgs.python3Packages.tomlkit ];
            flakeIgnore = [ "E501" ];
          }
          ''
            import sys
            import tomlkit
            from tomlkit.exceptions import ParseError


            def prune(live, static):
                """Drop entries Home Manager no longer declares from tables it owns."""
                for key, value in static.items():
                    if isinstance(value, dict) and key in live and isinstance(live[key], dict):
                        for stale in [k for k in live[key] if k not in value]:
                            del live[key][stale]


            def deep_merge(live, static):
                for key, value in static.items():
                    if key in live and isinstance(live[key], dict) and isinstance(value, dict):
                        deep_merge(live[key], value)
                    else:
                        live[key] = value


            live_path, static_path = sys.argv[1], sys.argv[2]
            try:
                with open(live_path) as handle:
                    live = tomlkit.parse(handle.read())
            except FileNotFoundError:
                live = tomlkit.document()
            except ParseError as err:
                sys.exit(f"{live_path} is not valid TOML, refusing to merge: {err}")
            with open(static_path) as handle:
                static = tomlkit.parse(handle.read())
            prune(live, static)
            deep_merge(live, static)
            sys.stdout.write(tomlkit.dumps(live))
          '';
    in
    {
      programs.codex = {
        enable = true;
        enableMcpIntegration = true;
      };

      home.file.".codex/config.toml".enable = false;

      home.activation.codexConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        if [[ -v DRY_RUN ]]; then
          echo "would merge codex settings into ${configFile}"
        else
          mkdir -p "$(dirname ${lib.escapeShellArg configFile})"
          ${mergeConfig} ${lib.escapeShellArg configFile} ${generated} \
            > ${lib.escapeShellArg configFile}.tmp
          mv ${lib.escapeShellArg configFile}.tmp ${lib.escapeShellArg configFile}
        fi
      '';
    };
}
