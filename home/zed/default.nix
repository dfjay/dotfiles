{ ... }:

{
  programs.zed-editor = {
    enable = true;
    extensions = [ 
      "catppuccin"
      "dockerfile" 
      "docker compose" 
      "git firefly"
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
    ];
    userSettings = {
      telemetry = {
        metrics = false;
      };
      vim_mode = true;
      autosave = "on_focus_change";
      ui_font_size = 14;
      buffer_font_size = 14;
      theme = {
        mode = "dark";
        light = "One Light";
        dark = "Catppuccin Mocha";
      };
      file_types = {
        Helm = [
          "**/templates/**/*.tpl"
          "**/templates/**/*.yaml"
          "**/templates/**/*.yml"
          "**/helmfile.d/**/*.yaml"
          "**/helmfile.d/**/*.yml"
        ];
      };
      lsp = {
        rust-analyzer = {
          binary = {
            path = "/run/current-system/sw/bin/rust-analyzer";
          };
        };
      };
    };
  };
}
