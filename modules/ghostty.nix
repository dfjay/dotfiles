{
  homeModule =
    { ... }:
    {
      programs.ghostty = {
        enable = true;
        settings = {
          cursor-style-blink = false;
        };
      };
    };

  darwinModule =
    { pkgs, username, ... }:
    {
      home-manager.users.${username}.programs.ghostty.package = pkgs.ghostty-bin;
    };
}
