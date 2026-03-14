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
          };
        };
      };
    };
}
