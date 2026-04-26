{ modules }:

{
  host = "dfjay-laptop";
  system = "aarch64-darwin";
  user = "dfjay";
  useremail = "mail@dfjay.com";

  darwinStateVersion = 6;
  homeStateVersion = "26.05";

  modules = with modules; [
    # system
    (darwin-aerospace {
      onWindowDetected = [
        {
          "if".app-id = "com.mitchellh.ghostty";
          check-further-callbacks = true;
          run = "layout floating";
        }
      ];
      workspaceMonitorAssignment = {
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
          "DELL U2725QE"
          "main"
        ];
        "4" = [
          "DELL U4025QW"
          "DELL U2725QE"
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
          "SSN-24"
          "DELL U2725QE"
          "built-in"
        ];
        "9" = [
          "SU13TO"
          "SSN-24"
          "DELL U2725QE"
          "built-in"
        ];
      };
    })
    darwin-macos
    firewall
    sops
    stylix

    # tools
    bat
    beam
    btop
    claude
    codex
    direnv
    docker
    eza
    fastfetch
    fd
    formats
    ghostty
    git
    go
    gpg
    helix
    js
    just
    jvm
    k8s
    lazydocker
    lazygit
    librewolf
    nix
    nix-index
    nushell
    python
    ripgrep
    rust
    skim
    ssh
    starship
    tailscale
    tealdeer
    yazi
    zed
    zoxide
    zsh

    # work
    spectrum
  ];

  config =
    { pkgs, username, ... }:
    {
      home-manager.users.${username} = {
        sops.age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
        sops.secrets."netrc".path = "/Users/${username}/.netrc";
        services.gpg-agent.pinentry.package = pkgs.pinentry_mac;
        services.gpg-agent.sshKeys = [
          "FB20142EEBEAA96FD7F688382F5E558BA4A23694" # YubiKey auth subkey
        ];
        programs.git.settings = {
          commit.gpgSign = true;
          tag.gpgSign = true;
          user.signingKey = "577260D68251AC22";
        };
      };

      environment.systemPackages = with pkgs; [
        # system
        devenv
        nh

        # CLI
        age
        colmena
        gh
        gitlab-ci-ls
        glab
        gopass
        jan
        k6
        openfortivpn
        postgresql
        rclone
        sing-box
        squawk
        xh
        yq-go
        yubikey-manager

        # GUI
        bitwarden-desktop
        discord
        iina
        logseq
        slack
        syncthing
        telegram-desktop
        yaak
      ];
      environment.variables.EDITOR = "hx";

      homebrew = {
        enable = true;

        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
        };

        masApps = {
          "Logic Pro" = 634148309;
          "TestFlight" = 899247664;
          "Xcode" = 497799835;
        };

        taps = [ ];

        brews = [
          "incus"
        ];

        casks = [
          "amneziavpn"
          "android-studio"
          "audio-hijack"
          "balenaetcher"
          "brave-browser"
          "claude"
          "draw-things"
          "figma"
          "intellij-idea"
          "libreoffice"
          "linearmouse"
          "loopback"
          "lulu"
          "mattermost"
          "melodics"
          "microsoft-excel"
          "microsoft-powerpoint"
          "microsoft-teams"
          "microsoft-word"
          "orion"
          "proxyman"
          "soundsource"
          "steam"
          "tableplus"
          "tor-browser"
          "tuta-mail"
          "windows-app"
          "yubico-authenticator"
        ];
      };
    };
}
