{ ... }:

# https://daiderd.com/nix-darwin/manual/index.html#sec-options
# https://github.com/yannbertrand/macos-defaults
{
  system = {
    defaults = {
      dock = {
        autohide = true;
        show-recents = false;

        # Hot-corners
        wvous-tl-corner = 1;  # top-left
        wvous-tr-corner = 1;  # top-right
        wvous-bl-corner = 1;  # bottom-left
        wvous-br-corner = 1;  # bottom-right
      };

      finder = {
        _FXShowPosixPathInTitle = true;  # show full path in finder title
        FXDefaultSearchScope = "SCcf";
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        # FXEnableExtensionChangeWarning = false;  # disable warning when changing file extension
        QuitMenuItem = true;  # enable quit menu item
        ShowPathbar = true;  # show path bar
        ShowStatusBar = true;  # show status bar
      };

      WindowManager = {
        EnableStandardClickToShowDesktop = false;
      };
    };

    keyboard = {
      enableKeyMapping = true;

      remapCapsLockToEscape = true;
    };
  };

  programs.zsh.enable = true;
}
