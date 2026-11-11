{
  homeModule =
    { pkgs, lib, ... }:

    let
      solidity-lsp = pkgs.writeShellScriptBin "nomicfoundation-solidity-language-server" ''
        exec ${pkgs.nodejs_26}/bin/node \
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

      imports = [
        (
          { options, ... }:
          {
            # nvf has no solidity language module, so wire the pieces by hand
            config = lib.optionalAttrs (options.programs ? nvf) {
              programs.nvf.settings.vim = {
                treesitter = {
                  enable = true;
                  grammars = [ pkgs.vimPlugins.nvim-treesitter.grammarPlugins.solidity ];
                };

                lsp.servers.solidity = {
                  cmd = [
                    (lib.getExe solidity-lsp)
                    "--stdio"
                  ];
                  filetypes = [ "solidity" ];
                  root_markers = [
                    "foundry.toml"
                    "hardhat.config.ts"
                    "hardhat.config.js"
                    ".git"
                  ];
                };

                formatter.conform-nvim = {
                  enable = true;
                  setupOpts = {
                    formatters_by_ft.solidity = [ "forge_fmt" ];
                    formatters.forge_fmt.command = lib.getExe' pkgs.foundry "forge";
                  };
                };
              };
            };
          }
        )
      ];
    };
}
