{ modules }:

{
  system = "aarch64-darwin";
  user = "dfjay";
  useremail = "mail@dfjay.com";

  darwinStateVersion = 6;
  homeStateVersion = "26.05";

  modules = with modules; [
    darwin-macos
    darwin-aerospace
    sops
    stylix

    claude
    bat
    direnv
    docker
    eza
    fastfetch
    fd
    formats
    ghostty
    git
    gpg
    helix
    btop
    k8s
    kitty
    lazydocker
    lazygit
    librewolf
    nushell
    neovim
    nix-index
    postgresql
    proto
    ripgrep
    skim
    ssh
    starship
    tealdeer
    vscode
    yazi
    zoxide
    netrc
    zsh

    languages.erlang
    languages.gleam
    languages.go
    languages.jdk
    languages.js
    languages.kotlin
    languages.python
    languages.rust
    languages.solidity
  ];

  config =
    { pkgs, username, ... }:
    {
      home-manager.users.${username} = {
        sops.age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
        services.gpg-agent.pinentry.package = pkgs.pinentry_mac;
        services.gpg-agent.sshKeys = [
          "FB20142EEBEAA96FD7F688382F5E558BA4A23694" # YubiKey auth subkey
        ];
        programs.git.settings = {
          commit.gpgSign = true;
          tag.gpgSign = true;
          user.signingKey = "577260D68251AC22";
        };
        programs.git.includes = [
          {
            path = "~/spectrum/.gitconfig";
            condition = "gitdir:~/spectrum/";
          }
        ];
      };

      environment.systemPackages = with pkgs; [
        nh
        age
        aria2
        colima
        colmena
        dive
        docker
        doggo
        docker-credential-helpers
        dua
        ffmpeg
        gh
        glab
        glow
        gopass
        jmeter
        just
        mkpasswd
        mkcert
        openfortivpn
        posting
        qrencode
        rclone
        sing-box
        sops
        squawk
        wabt
        xh
        yubikey-manager
        zulu

        # GUI
        bitwarden-desktop
        bruno
        iina
        slack
        syncthing
        telegram-desktop
        wireshark
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
          #"Logic Pro" = 634148309;
          "Shadowrocket" = 932747118;
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
          "chromium"
          "claude"
          "datagrip"
          "discord"
          "figma"
          "ghostty"
          "gpg-suite"
          "intellij-idea"
          "jan"
          "libreoffice"
          "linearmouse"
          "logseq"
          "loopback"
          "lulu"
          "mattermost"
          "melodics"
          "microsoft-excel"
          "microsoft-powerpoint"
          "microsoft-teams"
          "microsoft-word"
          "obs"
          "orion"
          "proxyman"
          "signal"
          "soundsource"
          "steam"
          "tor-browser"
          "tuta-mail"
          "windows-app"
          "yubico-authenticator"
        ];
      };
    };
}
