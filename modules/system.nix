{
  nixosModule =
    {
      pkgs,
      lib,
      hostname,
      ...
    }:

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
      };

      environment.systemPackages = with pkgs; [
        home-manager

        neovim
        git
        wget
        curl

        # browsers
        librewolf

        # sensors
        lm_sensors
        coolercontrol.coolercontrold
        coolercontrol.coolercontrol-ui-data

        pinentry-gnome3
        sbctl
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

      # Suppress systemd-machine-id-commit.service since machine-id is persisted via preservation
      systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

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
          systemd-boot.enable = lib.mkForce false;
          efi.canTouchEfiVariables = true;
        };

        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";

          autoGenerateKeys.enable = true;

          autoEnrollKeys = {
            enable = true;
            autoReboot = true;
          };
        };

        # Enable systemd in initrd (required for preservation)
        initrd.systemd.enable = true;

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

      system.stateVersion = "25.11";
    };
}
