{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  security.sudo.enable = false;
  security.sudo-rs = {
    enable = true;
    execWheelOnly = false;
  };

  virtualisation = {
    podman = {
      enable = true;
    };
    docker = {
      enable = true;
      rootless = {
        enable = false;
        setSocketVariable = false;
      };
    };
  };

  programs.dconf.enable = true;

  programs.coolercontrol = {
    enable = true;
    nvidiaSupport = true;
  };

  environment.systemPackages = with pkgs; [
    home-manager

    neovim
    git
    wget
    curl

    dmidecode
    stress

    # browsers
    firefox
    chromium

    # sensors
    lm_sensors
    coolercontrol.coolercontrold
    coolercontrol.coolercontrol-ui-data
    coolercontrol.coolercontrol-liqctld
  ];

  services = {
    flatpak.enable = true;
    printing.enable = true;
  };

  hardware.cpu.amd.updateMicrocode = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      enable = false;
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_zen;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  system.stateVersion = "25.05";
}
