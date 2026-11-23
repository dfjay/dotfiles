{
  darwinModule =
    { config, ... }:
    {
      # https://daiderd.com/nix-darwin/manual/index.html#sec-options
      # https://github.com/yannbertrand/macos-defaults
      system = {
        defaults = {
          dock = {
            autohide = true;
            autohide-delay = 86400.0;
            autohide-time-modifier = 0.0;
            magnification = false;
            mineffect = "scale";
            show-recents = false;
            orientation = "bottom";
            tilesize = 40;
            # AeroSpace guide: Mission Control shows its hidden windows too small otherwise
            expose-group-apps = true;
            # Hot-corners
            wvous-tl-corner = 1; # top-left
            wvous-tr-corner = 1; # top-right
            wvous-bl-corner = 1; # bottom-left
            wvous-br-corner = 1; # bottom-right
          };

          finder = {
            _FXShowPosixPathInTitle = true; # show full path in finder title
            FXDefaultSearchScope = "SCcf"; # Set search scope to directory
            AppleShowAllExtensions = true;
            AppleShowAllFiles = true;
            FXEnableExtensionChangeWarning = false;
            QuitMenuItem = true;
            ShowPathbar = true;
            ShowStatusBar = true;
            NewWindowTarget = "Home";
          };

          trackpad = {
            Clicking = false;
            TrackpadRightClick = true;
            TrackpadThreeFingerDrag = true;
          };

          NSGlobalDomain = {
            ApplePressAndHoldEnabled = false;
            KeyRepeat = 2;
            InitialKeyRepeat = 20;
          };

          screencapture = {
            location = "${config.users.users.${config.system.primaryUser}.home}/Pictures/Screenshots";
            type = "png";
          };

          WindowManager = {
            EnableStandardClickToShowDesktop = false;
          };

          loginwindow = {
            GuestEnabled = false;
            DisableConsoleAccess = true;
          };

          screensaver = {
            askForPassword = true;
            askForPasswordDelay = 0;
          };

          CustomUserPreferences = {
            "com.apple.desktopservices" = {
              DSDontWriteNetworkStores = true;
              DSDontWriteUSBStores = true;
            };

            "com.apple.AdLib" = {
              allowApplePersonalizedAdvertising = false;
              allowIdentifierForAdvertising = false;
            };

            "com.apple.assistant.support"."Assistant Enabled" = false;
            "com.apple.Siri".StatusMenuVisible = false;
            "com.apple.Siri".UserHasDeclinedEnable = true;

            # Spotlight → "Show Related Content" off: the rule's presence
            "com.apple.Spotlight".EnabledPreferenceRules = [ "Custom.relatedContents" ];
          };
        };

        keyboard = {
          enableKeyMapping = true;

          remapCapsLockToEscape = true;
        };
      };
    };

  homeModule =
    { pkgs, lib, ... }:

    {
      services.gpg-agent.pinentry.package = pkgs.pinentry_mac;

      home.activation.screenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/Pictures/Screenshots"
      '';
    };
}
