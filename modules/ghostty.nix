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
    { username, ... }:
    {
      homebrew.casks = [
        "ghostty"
      ];

      home-manager.users.${username}.programs.ghostty.package = null;
    };
}
