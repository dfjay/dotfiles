{
  homeModule =
    { pkgs, ... }:

    {
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
        settings = {
          cursor-style-blink = false;
        };
      };
    };

  darwinModule =
    { ... }:
    {
      homebrew.casks = [
        "ghostty"
      ];
    };
}
