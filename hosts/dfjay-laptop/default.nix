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
    formats
    ghostty
    git
    helix
    htop
    k8s
    kitty
    lazydocker
    lazygit
    librewolf
    nushell
    neovim
    postgresql
    proto
    ripgrep
    skim
    ssh
    starship
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
        programs.git.includes = [
          {
            path = "~/spectrum/.gitconfig";
            condition = "gitdir:~/spectrum/";
          }
        ];
      };

      environment.systemPackages = with pkgs; [
        age
        aria2
        colima
        colmena
        dive
        docker
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
        recode
        sing-box
        sops
        squawk
        wabt
        xh
        zulu

        # GUI
        bitwarden-desktop
        bruno
        cyberduck
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
          "gnupg"
          "incus"
          "pinentry-mac"
          "ykman"
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
