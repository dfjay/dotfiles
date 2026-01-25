{ modules }:

{
  system = "aarch64-darwin";
  user = "dfjay";

  darwinModules = with modules; [
    darwin-system
    darwin-macos
    darwin-aerospace
    stylix
  ];

  homeModules = with modules; [
    sops
    claude
    bat
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
    nvchad
    postgresql
    proto
    ripgrep
    skim
    ssh
    starship
    translateshell
    vscode
    yazi
    zed
    zoxide
    zsh
    languages.erlang
    languages.gleam
    languages.go
    languages.js
    languages.kotlin
    languages.python
    languages.rust
    languages.solidity
  ];

  config =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        age
        aria2
        colima
        colmena
        cookiecutter
        dive
        docker
        docker-credential-helpers
        dua
        ffmpeg
        gh
        glab
        glow
        gopass
        httpie
        insomnia
        jmeter
        just
        minio-client
        mkpasswd
        mkcert
        openfortivpn
        posting
        rclone
        recode
        sing-box
        sops
        wabt
        xh
        zulu

        # GUI
        bitwarden-desktop
        bruno
        cyberduck
        element-desktop
        iina
        keystore-explorer
        slack
        spotify
        syncthing
        telegram-desktop
        visualvm
        wireshark
        zotero
      ];
      environment.variables.EDITOR = "nvim";

      homebrew = {
        enable = true;

        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
        };

        masApps = {
          #"Logic Pro" = 634148309;
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
          "jdk-mission-control"
          "libreoffice"
          "linearmouse"
          "logseq"
          "loopback"
          "mattermost"
          "melodics"
          "memoryanalyzer"
          "microsoft-excel"
          "microsoft-powerpoint"
          "microsoft-teams"
          "microsoft-word"
          "obs"
          "orion"
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
