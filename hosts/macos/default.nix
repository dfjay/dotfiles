{ pkgs, ... }:

{
  imports = [ 
    ../../modules/darwin/system.nix
    ../../modules/darwin/macos.nix
    ../../modules/darwin/aerospace.nix
    ../../modules/darwin/stylix.nix
  ];

  environment.systemPackages = with pkgs; [
    audacity
    aria2
    bitwarden
    claude-code
    colima
    cookiecutter
    dbeaver-bin
    discord
    dive
    docker
    docker-credential-helpers
    dua
    gh
    glab
    gopass
    httpie
    jetbrains.idea-community
    insomnia
    just
    kitty
    lunarvim
    mkpasswd
    neovim
    openfortivpn
    posting
    slack
    spotify
    qbittorrent
    recode
    wabt
    zotero
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
      "Xcode" = 497799835;
    };

    taps = [
      "homebrew/services"
    ];

    brews = [
      "gnupg"
      "pinentry-mac"
      "incus"
    ];

    casks = [
      "audio-hijack"
      "balenaetcher"
      "beekeeper-studio"
      "claude"
      "cyberduck"
      "element"
      "figma"
      "ghostty"
      "gpg-suite"
      "iina"
      "intellij-idea"
      "jdk-mission-control"
      "keepassxc"
      "libreoffice"
      "linearmouse"
      "logseq"
      "loopback"
      "mattermost"
      "memoryanalyzer"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "obs"
      "obsidian"
      "poe"
      "raycast"
      "soundsource"
      "steam"
      "syncthing-app"
      "telegram-desktop"
      "tor-browser"
      "tuta-mail"
      "visualvm"
      "vmware-fusion"
      "waterfox"
      "yubico-authenticator"
    ];
  };
}
