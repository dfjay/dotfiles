{
  homeModule =
    { pkgs, lib, ... }:

    {
      imports = [
        (
          { options, ... }:
          {
            config = lib.optionalAttrs (options.programs ? nvf) {
              programs.nvf.settings.vim = {
                lsp.enable = true;
                languages = {
                  typescript = {
                    enable = true;
                    lsp.servers = [ "typescript-go" ];
                    format.type = [ "biome" ];
                    extraDiagnostics.types = [ "biomejs" ];
                  };
                  svelte = {
                    enable = true;
                    extraDiagnostics.enable = false;
                  };
                };
              };
            };
          }
        )
      ];

      home.packages = with pkgs; [
        biome
        bun
        nodejs_26
        npm-check-updates
        svelte-language-server
        tsx
        typescript-language-server
      ];

      programs.zed-editor.extensions = [
        "biome"
        "svelte"
        "vue"
      ];

      programs.claude-code.settings.enabledPlugins."typescript-lsp@claude-plugins-nix" = true;

      programs.claude-code.settings.permissions.allow = [
        "Bash(npm run *)"
        "Bash(npm test *)"
      ];
    };
}
