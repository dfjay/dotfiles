{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        cargo
        rustc
        rustfmt
        clippy
        rust-analyzer
        rustlings
      ];

      home.sessionVariables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
    };
}
