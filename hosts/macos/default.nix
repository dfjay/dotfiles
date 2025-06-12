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
    docker
    docker-credential-helpers
    gh
    git
    gopass
    httpie
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
      "balenaetcher"
      "beekeeper-studio"
      "cyberduck"
      "deepl"
      "element"
      "firefox@developer-edition"
      "gpg-suite"
      "iina"
      "intellij-idea"
      "intellij-idea-ce"
      "jdk-mission-control"
      "keepassxc"
      "libreoffice"
      "linearmouse"
      "logseq"
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
      "syncthing"
      "telegram-desktop"
      "tor-browser"
      "tuta-mail"
      "visualvm"
      "vmware-fusion"
      "yubico-authenticator"
    ];
  };
}
