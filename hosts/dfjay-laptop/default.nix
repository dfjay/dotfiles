{ modules, profiles, ... }:

{
  system = "aarch64-darwin";
  user = "dfjay";
  useremail = "mail@dfjay.com";

  darwinStateVersion = 6;
  homeStateVersion = "26.11";

  modules =
    profiles.workstation
    ++ (with modules; [
      # system
      aerospace
      macos

      # tools
      codex
      opencode
      rclone
      web3

      # work
      spectrum
    ]);

  config =
    { pkgs, username, ... }:
    {
      home-manager.users.${username} = {
        sops.age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
        sops.secrets."netrc".path = "/Users/${username}/.netrc";

        home.packages = with pkgs; [
          # CLI
          age
          container
          gitlab-ci-ls
          glab
          k6
          protobuf
          sing-box
          squawk
          xh
          yq-go

          # GUI
          element-desktop
          iina
          jan
          #logseq
          mos
          obsidian
          telegram-desktop
          tutanota-desktop
          yaak
        ];
      };

      services.aerospace.settings = {
        on-window-detected = [
          {
            "if".app-id = "com.mitchellh.ghostty";
            check-further-callbacks = true;
            run = "layout floating";
          }
          {
            "if".app-id = "org.torproject.torbrowser";
            check-further-callbacks = true;
            run = "layout floating";
          }
        ];

        workspace-to-monitor-force-assignment = {
          "1" = [
            "DELL U4025QW"
            "built-in"
            "main"
          ];
          "2" = [
            "DELL U4025QW"
            "built-in"
            "main"
          ];
          "3" = [
            "DELL U4025QW"
            "built-in"
            "main"
          ];
          "4" = [
            "DELL U4025QW"
            "built-in"
            "main"
          ];
          "5" = [
            "DELL U4025QW"
            "DELL U2725QE"
            "main"
          ];
          "6" = [
            "DELL U4025QW"
            "DELL U2725QE"
            "main"
          ];
          "7" = [
            "DELL U4025QW"
            "DELL U2725QE"
            "main"
          ];
          "8" = [
            "SU13TO"
            "DELL U2725QE"
            "built-in"
          ];
          "9" = [
            "SU13TO"
            "DELL U2725QE"
            "built-in"
          ];
        };
      };

      environment.variables.EDITOR = "hx";

      homebrew = {
        enable = true;

        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
        };

        masApps = {
          "Keynote" = 361285480;
          "Logic Pro" = 634148309;
          "Numbers" = 361304891;
          "Pages" = 361309726;
          "TestFlight" = 899247664;
          "Xcode" = 497799835;
        };

        brews = [ ];

        casks = [
          "brave-browser"
          "cryptomator"
          "draw-things"
          "intellij-idea"
          "loopback"
          "lulu"
          "sfm"
          "signal"
          "soundsource"
          "steam"
          "tor-browser"
        ];
      };
    };
}
