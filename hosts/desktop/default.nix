{
  pkgs,
  lib,
  username,
  userdesc,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    (import ../../modules/audio.nix).nixosModule
    (import ../../modules/bluetooth.nix).nixosModule
    (import ../../modules/de/cosmic.nix).nixosModule
    (import ../../modules/flatpak.nix).nixosModule
    (import ../../modules/games.nix).nixosModule
    (import ../../modules/locale.nix).nixosModule
    (import ../../modules/shell/zsh.nix).nixosModule
    (import ../../modules/system.nix).nixosModule
    (import ../../modules/stylix.nix).nixosModule
  ];

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users.${username} = {
      isNormalUser = true;
      description = userdesc;
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      hashedPassword = "$6$J91OG.NW1Dz35n2S$L8pwihewop1tEe.x6YbjYIHRgyyax9E.q.mu/HL49xZkJEVD8DzKn.9s2rWJLWrJuL1WdpJ9NzymWQvJMBro8.";
    };
  };

  services.v2raya.enable = true;

  environment.systemPackages = with pkgs; [
    android-studio
    bitwarden-desktop
    brave
    claude-code
    discord
    element-desktop
    gnumake
    gopass
    gpg-tui
    grimblast
    jetbrains.idea-ultimate
    jmeter
    just
    libreoffice-qt
    lunarvim
    prismlauncher
    qbittorrent
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

  services.flatpak.packages = [
    "com.spotify.Client"
  ];

  programs.nekoray = {
    enable = true;
    tunMode.enable = true;
  };
}
