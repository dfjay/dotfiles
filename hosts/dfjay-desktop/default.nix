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
      de.cosmic
      games
      locale
    ]);

  config =
    {
      pkgs,
      lib,
      inputs,
      hostname,
      username,
      userdesc,
      ...
    }:
    {
      imports = [
        inputs.nixos-facter-modules.nixosModules.facter
        ./storage.nix
      ];

      facter.reportPath = ./facter.json;

      security.sudo.enable = false;
      security.sudo-rs = {
        enable = true;
        execWheelOnly = false;
      };

      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      sops.gnupg.sshKeyPaths = [ ];

      security = {
        polkit.enable = true;
      };

      # Suppress systemd-machine-id-commit.service since machine-id is persisted via preservation
      systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

      services.printing.enable = true;

      services.fwupd.enable = true;

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
        firewall.trustedInterfaces = [ "tailscale0" ];
      };

      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      services.displayManager.autoLogin = {
        enable = true;
        user = username;
      };

      systemd.sleep.settings.Sleep = {
        AllowSuspend = "no";
        AllowHibernation = "no";
        AllowHybridSleep = "no";
        AllowSuspendThenHibernate = "no";
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
        initrd.systemd.enable = true;
        kernelPackages = pkgs.linuxPackages_zen;
      };

      home-manager.users.${username} = {
        sops.gnupg.home = "/home/${username}/.gnupg";
        sops.secrets."netrc".path = "/home/${username}/.netrc";
        programs.git.includes = [
          {
            path = "~/code/work/.gitconfig";
            condition = "gitdir:~/code/work/";
          }
        ];

        systemd.user.services.lock-on-login = {
          Unit = {
            Description = "Lock the autologin session";
            After = [ "graphical-session.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "lock-on-login" ''
              for _ in 1 2 3 4 5; do
                ${pkgs.systemd}/bin/loginctl lock-session auto
                sleep 2
              done
            '';
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        home.packages = with pkgs; [
          # CLI
          gnumake
          home-manager
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
          hashedPassword = "$6$J91OG.NW1Dz35n2S$L8pwihewop1tEe.x6YbjYIHRgyyax9E.q.mu/HL49xZkJEVD8DzKn.9s2rWJLWrJuL1WdpJ9NzymWQvJMBro8.";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFmvdG0pEwUZcsrElS/5B+jR9PYfEECrtgy8VLs5pwR yubikey"
          ];
        };
      };

      environment.systemPackages = with pkgs; [
        lm_sensors
        sbctl
        usbutils
      ];

      environment.variables.EDITOR = "hx";

      programs.throne = {
        enable = true;
        tunMode.enable = true;
      };
    };
}
