{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = [
        (pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-analyzer"
            "rust-src"
          ];
        })
        pkgs.rustlings
      ];
    };
}
