{ pkgs, ... }:

{
  imports = [ 
    ../../modules/darwin/system.nix
    ../../modules/darwin/macos.nix
    ../../modules/darwin/aerospace.nix
    ../../modules/darwin/stylix.nix
  ];

  environment.systemPackages = with pkgs; [
    aria2
    claude-code
    colima
    cookiecutter
    dive
    docker
    docker-credential-helpers
    dua
    gh
    glab
    glow
    gopass
    httpie
    insomnia
    just
    lunarvim
    minio-client
    mkpasswd
    neovim
    openfortivpn
    posting
    qbittorrent
    rclone
    recode
    wabt
    xh
    zulu
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
      "GarageBand" = 682658836;
      #"Logic Pro" = 634148309;
      "Xcode" = 497799835;
    };

    taps = [];

    brews = [
      "gnupg"
      "incus"
      "pinentry-mac"
      "ykman"
    ];

    casks = [
      "amneziavpn"
      "audio-hijack"
      "balenaetcher"
      "beekeeper-studio"
      "bitwarden"
      "claude"
      "cyberduck"
      "datagrip"
      "discord"
      "element"
      "figma"
      "fleet"
      "ghostty"
      "gpg-suite"
      "iina"
      "intellij-idea"
      "jdk-mission-control"
      "libreoffice"
      "linearmouse"
      "logseq"
      "loopback"
      "mattermost"
      "memoryanalyzer"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-teams"
      "microsoft-word"
      "obs"
      "obsidian"
      "orion"
      "raycast"
      "slack"
      "soundsource"
      "spotify"
      "steam"
      "syncthing-app"
      "telegram-desktop"
      "tor-browser"
      "tuta-mail"
      "visualvm"
      "vmware-fusion"
      "waterfox"
      "yubico-authenticator"
      "zotero"
    ];
  };
}
