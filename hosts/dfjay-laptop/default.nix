{ modules }:

{
  host = "dfjay-laptop";
  system = "aarch64-darwin";
  user = "dfjay";
  useremail = "mail@dfjay.com";

  darwinStateVersion = 6;
  homeStateVersion = "26.11";

  modules = with modules; [
    # system
    (aerospace {
      onWindowDetected = [
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
          "built-in"
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
          "DELL U2725QE"
          "SSN-24"
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
    firewall
    macos
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
    fd
    fish
    formats
    gh
    ghostty
    (git {
      signingKey = "A82705DF08BC95859FF5CB7E577260D68251AC22"; # YubiKey primary key [SC]
    })
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
    mcp
    nh
    nix
    nix-index
    nushell
    opencode
    pgcli
    python
    rclone
    ripgrep
    rust
    skills
    skim
    ssh
    starship
    tailscale
    tealdeer
    web3
    yazi
    zed
    zoxide

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
      };

      environment.systemPackages = with pkgs; [
        # system
        devenv

        # CLI
        age
        colmena
        container
        gitlab-ci-ls
        glab
        gopass
        gpg-tui
        k6
        postgresql
        protobuf
        sing-box
        squawk
        xh
        yq-go
        yubikey-manager

        # GUI
        element-desktop
        iina
        jan
        #logseq
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
          "draw-things"
          "intellij-idea"
          "loopback"
          "lulu"
          "mos"
          "signal"
          "soundsource"
          "steam"
          "tor-browser"
          "tuta-mail"
        ];
      };
    };
}
