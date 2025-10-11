{ pkgs, hostname, ... }:

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

    pinentry
    sops
  ];

  security = {
    pam.services = {
      login = {
        enableGnomeKeyring = true;
      };
      logind.enableGnomeKeyring = true;
    };

    polkit.enable = true;
  };

  sops = {
    defaultSopsFile = ../secrets/secret.yaml;
    defaultSopsFormat = "yaml";
  };

  services.printing.enable = true;

  hardware = {
    cpu.amd.updateMicrocode = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  networking = {
    hostName = hostname;
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
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  system.stateVersion = "25.05";
}
