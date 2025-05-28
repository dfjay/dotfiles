{ pkgs, username, ... }:

{
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm.enable = false;
    };
  };

  security = {
    polkit.enable = true;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs = {
    kdeconnect.enable = true;
    dconf.enable = true;
  };

  security.pam.services.hyprlock = {};

  environment.systemPackages = with pkgs; [
    morewaita-icon-theme
    adwaita-icon-theme
    qogir-icon-theme
    nautilus
    gnome-calendar
    gnome-weather
    gnome-calculator
    gnome-software
    gnome-system-monitor

    wl-clipboard

    # screenshot tools
    grim
    slurp

    # volume control
    pavucontrol

    # automount usb
    udiskie

    hyprland-qtutils
  ];

  services = {
    gvfs.enable = true;
    udisks2.enable = true;
    devmon.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = "${username}";    
      };
      
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --greeting 'Welcome to NixOS' --asterisks --remember --remember-user-session --time -cmd uwsm start hyprland-uwsm.desktop";
        user = "greeter";
      };
    };
  };

  nix = {
    settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  };
}
