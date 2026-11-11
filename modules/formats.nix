{
  homeModule =
    { pkgs, lib, ... }:

    {
      home.packages = with pkgs; [
        actionlint
        bash-language-server
        bats
        marksman
        shellcheck
        taplo
        vscode-langservers-extracted
        yaml-language-server
      ];

      programs.claude-code.lspServers = {
        yaml = {
          command = lib.getExe pkgs.yaml-language-server;
          args = [ "--stdio" ];
          extensionToLanguage = {
            ".yaml" = "yaml";
            ".yml" = "yaml";
          };
        };
        toml = {
          command = lib.getExe pkgs.taplo;
          args = [
            "lsp"
            "stdio"
          ];
          extensionToLanguage = {
            ".toml" = "toml";
          };
        };
      };
    };
}
