{
  homeModule =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      imports = [
        (
          { options, ... }:
          {
            config = lib.optionalAttrs (options.programs ? nvf) {
              programs.nvf.settings.vim = {
                lsp.enable = true;
                languages.rust.enable = true;
                lsp.servers.rust-analyzer.cmd = lib.mkForce [
                  "${config.home.profileDirectory}/bin/rust-analyzer"
                ];
              };
            };
          }
        )
      ];

      home.packages = [
        (pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-analyzer"
            "rust-src"
          ];
        })
      ];
    };
}
