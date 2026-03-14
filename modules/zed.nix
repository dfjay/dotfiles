{
  homeModule =
    { ... }:

    {
      programs.zed-editor = {
        enable = true;
        extensions = [
          "dockerfile"
          "docker-compose"
          "git-firefly"
          "helm"
          "nix"
          "java"
          "kotlin"
          "html"
          "sql"
          "svelte"
          "vue"
          "toml"
          "golangci-lint"
          "justfile"
          "make"
          "elixir"
          "gleam"
          "graphql"
          "proto"
          "xml"
          "zig"

          "colored-zed-icons-theme"
          "ayu-darker-theme"

          # MCP
          "mcp-server-context7"
        ];
        userSettings = {
          telemetry = {
            metrics = false;
          };
          icon_theme = "Colored Zed Icons Theme Dark";
          vim_mode = true;
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
              language_servers = [ "nixd" "!nil" ];
            };
          };
        };
      };
    };
}
