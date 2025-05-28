{ pkgs, username, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./disk-config.nix
    ./impermanence.nix
    ../../modules/audio.nix
    ../../modules/dewm/hyprland.nix
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
    gnumake
    just
    tuifimanager
    wineWowPackages.stable
    winetricks
    rustup

    spotify
    nekoray
    telegram-desktop
    usbutils
    via

    prismlauncher
    tor-browser
    element-desktop
    lunarvim
    brave
    libreoffice-qt
    bitwarden-desktop
    nekoray
    jetbrains.idea-community
    v2rayn

    grimblast

    hiddify-app

    gpg-tui
    gopass

    gui-for-singbox

    glmark2
    furmark
    qbittorrent
    woeusb
  ];
}
