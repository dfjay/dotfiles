{ modules, profiles, ... }:

{
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  userdesc = "Pavel Yozhikov";

  nixosStateVersion = "25.11";
  homeStateVersion = "26.11";

  modules =
    profiles.workstation
    ++ (with modules; [
      # system
      audio
      bluetooth
      desktop.hyprland
      desktop.noctalia
      games
      locale
    ]);

  config =
    {
      config,
      pkgs,
      lib,
      hostname,
      username,
      userdesc,
      ...
    }:
    {
      imports = [ ./storage.nix ];

      hardware.facter = {
        reportPath = ./facter.json;
        detected.dhcp.enable = false;
      };
      system.tools.nixos-generate-config.enable = false;

      sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
      sops.secrets.dfjay_password_hash = {
        sopsFile = ../../secrets/desktop.yaml;
        neededForUsers = true;
      };

      security = {
        sudo-rs.enable = true;
        polkit.enable = true;

        pam.services = {
          sudo.u2f.enable = true;
          sudo-i.u2f.enable = true;
          polkit-1.u2f.enable = true;
          login.u2f.enable = true;

          greetd = {
            useDefaultRules = lib.mkForce true;
            rules = lib.genAttrs [ "auth" "account" "password" "session" ] (_: {
              login.enable = false;
            });
            startSession = true;
            enableGnomeKeyring = true;
          };
        };
      };

      # Suppress systemd-machine-id-commit.service since machine-id is persisted via preservation
      systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

      services.printing.enable = true;
      services.speechd.enable = false;

      networking = {
        hostName = hostname;
        networkmanager.enable = true;
        nftables.enable = true;
        firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];
      };

      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      programs.kdeconnect.enable = true;

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
        kernelPackages = pkgs.linuxPackages_latest;
      };

      home-manager.users.${username} = {
        sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
        sops.secrets."netrc" = {
          sopsFile = ../../secrets/personal.yaml;
          path = "/home/${username}/.netrc";
        };
        programs.git.includes = [
          {
            path = "~/code/work/.gitconfig";
            condition = "gitdir:~/code/work/";
          }
        ];

        home.packages = with pkgs; [
          # CLI
          gnumake
          k6

          # GUI
          discord
          libreoffice-qt
          pwvucontrol
          telegram-desktop
          tor-browser
          tutanota-desktop
          via
        ];
      };

      services.userborn = {
        enable = true;
        passwordFilesLocation = "/var/lib/nixos";
      };

      system.etc.overlay.enable = true;
      system.nixos-init.enable = true;

      users = {
        defaultUserShell = pkgs.fish;
        mutableUsers = false;
        users.${username} = {
          isNormalUser = true;
          description = userdesc;
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          hashedPasswordFile = config.sops.secrets.dfjay_password_hash.path;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOit5gYKGOh6Wwy3Q/nyLpyN8tg/vDjpNiXQc7dIV27 openpgp:0x830BAD41"
          ];
        };
      };

      environment.systemPackages = with pkgs; [
        lm_sensors
        sbctl
        usbutils
      ];

      environment.variables.EDITOR = "nvim";

      programs.throne = {
        enable = true;
        tunMode.enable = true;
      };
    };
}
