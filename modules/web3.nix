{
  homeModule =
    { pkgs, lib, ... }:

    let
      solidity-lsp = pkgs.writeShellScriptBin "nomicfoundation-solidity-language-server" ''
        exec ${pkgs.nodejs_24}/bin/node \
          ${pkgs.vscode-extensions.nomicfoundation.hardhat-solidity}/share/vscode/extensions/nomicfoundation.hardhat-solidity/server/out/index.js "$@"
      '';
    in
    {
      home.packages = with pkgs; [
        foundry
        solc
        slither-analyzer
        solidity-lsp

        solana-cli
        anchor
      ];

      programs.helix.languages = {
        language-server.solidity = {
          command = lib.getExe solidity-lsp;
          args = [ "--stdio" ];
        };
        language = [
          {
            name = "solidity";
            language-servers = [ "solidity" ];
            formatter = {
              command = lib.getExe' pkgs.foundry "forge";
              args = [
                "fmt"
                "--raw"
                "-"
              ];
            };
            auto-format = true;
          }
        ];
      };
    };
}
