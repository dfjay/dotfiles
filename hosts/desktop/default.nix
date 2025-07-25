{ pkgs, username, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./disk-config.nix
    ./impermanence.nix
    ../../modules/stylix.nix
    ../../modules/audio.nix
    ../../modules/dewm/cosmic.nix
    ../../modules/locale.nix
    ../../modules/system.nix
    ../../modules/games.nix
    ../../modules/bluetooth.nix
    ../../modules/shell/zsh.nix
  ];

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users.${username} = {
      isNormalUser = true;
      description = "Pavel Yozhikov";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      hashedPassword = "$6$J91OG.NW1Dz35n2S$L8pwihewop1tEe.x6YbjYIHRgyyax9E.q.mu/HL49xZkJEVD8DzKn.9s2rWJLWrJuL1WdpJ9NzymWQvJMBro8.";
    };
  };

  services.v2raya.enable = true;

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    brave
    element-desktop
    furmark
    glmark2
    gnumake
    gopass
    gpg-tui
    grimblast
    gui-for-singbox
    hiddify-app
    jetbrains.idea-community
    just
    libreoffice-qt
    lunarvim
    nekoray
    prismlauncher
    qbittorrent
    rustup
    spotify
    telegram-desktop
    tor-browser
    tuifimanager
    usbutils
    via
    v2rayn
    winetricks
    wineWowPackages.stable
    woeusb
  ];
}
