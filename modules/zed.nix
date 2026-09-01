{
  homeModule =
    { pkgs, config, ... }:

    let
      inherit (config.stylix.fonts) monospace;
    in
    {
      stylix.targets.zed.colors.enable = false;
      stylix.targets.zed.fonts.enable = false;

      programs.zed-editor = {
        enable = true;
        enableMcpIntegration = true;
        extensions = [
          "docker-compose"
          "dockerfile"
          "editorconfig"
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
          "solidity"
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
        ];
        userSettings = {
          theme = "Ayu Dark";
          ui_font_family = monospace.name;
          buffer_font_family = monospace.name;
          ui_font_size = 14;
          buffer_font_size = 13;
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
          icon_theme = "Colored Zed Icons Theme Dark";
          vim_mode = true;
          helix_mode = true;
          cursor_blink = false;
          relative_line_numbers = "enabled";
          scroll_beyond_last_line = "off";
          wrap_guides = [ 100 ];
          "unstable.ui_density" = "compact";
          scrollbar = {
            show = "never";
          };
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
          lsp = {
            rust-analyzer = {
              binary = {
                path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
              };
            };
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
            # Ruler overrides matching each formatter's wrap point.
            Python = {
              wrap_guides = [ 88 ];
            };
          };
        };
      };

    };
}
