{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
    };
    desktopManager.gnome = {
      enable = true;
    };
  };

  programs.dconf.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    geary
  ];

  # Gnome extensions
  environment.systemPackages = with pkgs.gnomeExtensions; [
    dash-to-dock
    blur-my-shell
    gsconnect
  ];
}
