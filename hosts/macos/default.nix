{ ... }:

{
  imports = [ 
    ./modules/nixcore.nix
    ./modules/macos.nix
    ./modules/aerospace.nix
  ];

  environment.systemPackages = with pkgs; [
    wget
    curl
    aria2
    httpie
    neovim
    lunarvim
    git
    just
    mkpasswd
    openfortivpn
    cookiecutter
    recode
    colima
    docker
    docker-credential-helpers
    zulu
    gopass
    posting
    qbittorrent
    gh
    claude-code
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
      "libreoffice"
      "microsoft-excel"
      "microsoft-word"
      "microsoft-powerpoint"

      "firefox@developer-edition"
      "tor-browser"
       
      "syncthing"
      "logseq"
      "obsidian"
      "zotero"
      "poe"

      "telegram-desktop"
      "discord"
      "slack"
      "mattermost"
      "element"
      "tuta-mail"
      "spotify"
      "deepl"
      "obs"
      "audacity"
 
      "soundsource"
      "iina"
      "maccy"

      "kitty"
      "insomnia"
      "visual-studio-code"
      "visualvm" # DEL (home nix)
      "wireshark"
      "balenaetcher"
      "dbeaver-community"
      "beekeeper-studio"
      "memoryanalyzer" # DEL (home nix)
      "jdk-mission-control" # DEL (home nix)
      "vmware-fusion"
      "virtualbox"
      "cyberduck"
      #"vagrant" # only proxy
      "intellij-idea" # only proxy
      "intellij-idea-ce"

      "keepassxc"
      "bitwarden"
      "yubico-authenticator"
      "gpg-suite"

      # Mac utilities
      "linearmouse"
      "raycast"
    ];
  };
}
