{
  homeModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      inherit (config.stylix.fonts) monospace sansSerif;
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

          "jetbrains-themes"
          "jetbrains-new-ui-icons"
        ];
        userSettings = {
          theme = "JetBrains Islands Dark";
          icon_theme = "JetBrains New UI Icons (Dark)";
          ui_font_family = sansSerif.name;
          buffer_font_family = monospace.name;
          ui_font_size = 15;
          buffer_font_size = 13;
          "unstable.ui_density" = "compact";

          toolbar = {
            breadcrumbs = false;
            quick_actions = false;
          };
          tab_bar.show_nav_history_buttons = false;
          tabs = {
            file_icons = true;
            git_status = true;
            show_diagnostics = "errors";
          };
          scrollbar = {
            show = "always";
            git_diff = true;
            diagnostics = "all";
            search_results = true;
          };
          project_panel = {
            dock = "right";
            folder_indicator = "both";
          };
          outline_panel.dock = "right";
          collaboration_panel.dock = "right";
          git_panel.tree_view = false;

          cursor_blink = false;
          relative_line_numbers = "enabled";
          scroll_beyond_last_line = "off";
          wrap_guides = [ 100 ];
          sticky_scroll.enabled = true;
          inlay_hints = {
            enabled = true;
            show_background = true;
          };
          git.inline_blame.delay_ms = 1000;
          auto_signature_help = false;
          show_signature_help_after_edits = true;
          hover_popover_delay = 550;
          colorize_brackets = true;
          use_smartcase_search = true;
          autosave = "on_focus_change";

          base_keymap = "JetBrains";
          vim_mode = true;
          helix_mode = true;
          vim.toggle_relative_line_numbers = true;
          which_key = {
            enabled = true;
            delay_ms = 400;
          };

          agent = {
            dock = "left";
            commit_message_model = {
              provider = "anthropic";
              model = "claude-haiku-5-5";
            };
            favorite_models = [ ];
            model_parameters = [ ];
          };
          agent_servers = {
            "claude-acp".type = "registry";
            "codex-acp".type = "registry";
          };

          telemetry.metrics = false;

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
          lsp.rust-analyzer.binary.path = "${config.home.profileDirectory}/bin/rust-analyzer";
          lsp.kotlin-lsp.binary = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
            path = lib.getExe pkgs.kotlin-lsp-proxy;
            arguments = [
              (lib.getExe pkgs.kotlin-lsp)
              "--stdio"
            ];
          };
          lsp.gopls.initialization_options.hints = {
            assignVariableTypes = false;
            rangeVariableTypes = false;
            compositeLiteralTypes = false;
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
