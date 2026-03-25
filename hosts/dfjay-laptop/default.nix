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
    darwin-aerospace
    darwin-macos
    sops
    stylix

    # tools
    bat
    btop
    claude
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
    k8s
    lazydocker
    lazygit
    librewolf
    neovim
    nix-index
    nushell
    postgresql
    proto
    ripgrep
    skim
    ssh
    starship
    tealdeer
    yazi
    zed
    zoxide
    zsh

    # languages
    languages.erlang
    languages.gleam
    languages.go
    languages.jdk
    languages.js
    languages.kotlin
    languages.nix
    languages.python
    languages.rust
    languages.solidity
    languages.zig
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
        programs.git.includes = [
          {
            path = "~/spectrum/.gitconfig";
            condition = "gitdir:~/spectrum/";
          }
        ];
      };

      environment.systemPackages = with pkgs; [
        # system
        devenv
        nh
        sops

        # CLI
        age
        aria2
        colima
        colmena
        dive
        docker
        docker-credential-helpers
        doggo
        dua
        ffmpeg
        gh
        glab
        glow
        gopass
        jmeter
        just
        mkcert
        mkpasswd
        openfortivpn
        posting
        qrencode
        rclone
        sing-box
        squawk
        wabt
        xh
        yubikey-manager
        zulu

        # GUI
        bitwarden-desktop
        iina
        slack
        syncthing
        telegram-desktop
        wireshark
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
          "rustrover"
          "signal"
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
