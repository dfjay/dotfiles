{ pkgs, pkgs-master, ... }:

{
  environment.systemPackages = with pkgs; [
    age
    aria2
    pkgs-master.claude-code
    colima
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
    sops
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
      "bitwarden"
      "brave-browser"
      "bruno"
      "claude"
      "clash-verge-rev"
      "cyberduck"
      "datagrip"
      "discord"
      "element"
      "figma"
      "ghostty"
      "goland"
      "gpg-suite"
      "iina"
      "intellij-idea"
      "jan"
      "jdk-mission-control"
      "keystore-explorer"
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
      "obsidian"
      "orion"
      "rustrover"
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
      "windows-app"
      "wireshark-app"
      "yubico-authenticator"
      "zotero"
    ];
  };
}
