{
  homeModule =
    { ... }:

    {
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
          telemetry = {
            metrics = false;
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
            tree_view = true;
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
    };
}
