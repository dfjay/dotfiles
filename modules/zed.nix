{
  homeModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      stylix.targets.zed.colors.enable = false;

      sops.secrets.context7_api_key = { };

      programs.zed-editor = {
        enable = true;
        extensions = [
          "docker-compose"
          "dockerfile"
          "elixir"
          "gleam"
          "graphql"
          "helm"
          "html"
          "java"
          "justfile"
          "kotlin"
          "make"
          "nix"
          "proto"
          "sql"
          "svelte"
          "toml"
          "vue"
          "xml"
          "zig"

          "biome"
          "git-firefly"
          "gitlab-ci-ls"
          "golangci-lint"

          "ayu-darker-theme"
          "colored-zed-icons-theme"

          "mcp-server-context7"
        ];
        userSettings = {
          theme = "Ayu Dark";
          telemetry = {
            metrics = false;
          };
          agent_servers = {
            "claude-acp" = {
              type = "registry";
            };
            "codex-acp" = {
              type = "registry";
            };
          };
          project_panel = {
            dock = "right";
          };
          outline_panel = {
            dock = "right";
          };
          collaboration_panel = {
            dock = "right";
          };
          agent = {
            dock = "left";
            favorite_models = [ ];
            model_parameters = [ ];
          };
          context_servers = {
            "mcp-server-context7" = {
              enabled = true;
            };
          };
          icon_theme = "Colored Zed Icons Theme Dark";
          vim_mode = true;
          helix_mode = true;
          cursor_blink = false;
          relative_line_numbers = "enabled";
          scroll_beyond_last_line = "off";
          vim = {
            toggle_relative_line_numbers = true;
          };
          autosave = "on_focus_change";
          file_types = {
            Helm = [
              "**/templates/**/*.tpl"
              "**/templates/**/*.yaml"
              "**/templates/**/*.yml"
              "**/helmfile.d/**/*.yaml"
              "**/helmfile.d/**/*.yml"
              "**/values*.yaml"
            ];
          };
          git_panel = {
            tree_view = false;
          };
          languages = {
            Kotlin = {
              language_servers = [ "kotlin-lsp" ];
            };
            Nix = {
              language_servers = [
                "nixd"
                "!nil"
              ];
            };
          };
        };
      };

      home.activation.zedContext7Secret =
        lib.hm.dag.entryAfter
          [
            "zedSettingsActivation"
            "sops-nix"
          ]
          ''
            secret_path=${lib.escapeShellArg config.sops.secrets.context7_api_key.path}
            settings_file=${lib.escapeShellArg "${config.xdg.configHome}/zed/settings.json"}

            for _ in 1 2 3 4 5; do
              [ -r "$secret_path" ] && break
              sleep 1
            done

            if [ -r "$secret_path" ] && [ -f "$settings_file" ]; then
              api_key=$(cat "$secret_path")
              tmp=$(${pkgs.coreutils}/bin/mktemp)
              ${pkgs.jq}/bin/jq \
                --arg key "$api_key" \
                '.context_servers["mcp-server-context7"].settings.context7_api_key = $key' \
                "$settings_file" > "$tmp" \
                && mv "$tmp" "$settings_file"
              chmod 600 "$settings_file"
            fi
          '';
    };
}
