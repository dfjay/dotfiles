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
      config,
      pkgs,
      lib,
      inputs,
      hostname,
      username,
      userdesc,
      ...
    }:
    {
      imports = [ ./storage.nix ];

      hardware.facter.reportPath = ./facter.json;

      sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
      sops.secrets.dfjay_password_hash = {
        sopsFile = ../../secrets/desktop.yaml;
        neededForUsers = true;
      };

      security.pam.u2f.settings = {
        authfile = "/etc/u2f-mappings";
        cue = true;
      };
      environment.etc."u2f-mappings".text = lib.concatStringsSep ":" [
        username
        "TJsm3V7hBAhRxztwfcVAHJbDLZQ3RW/8+K0Tpw9t/P16sVF7xfqO0PtFOJPrts8krMQQTo5lxXSKPLCML4U02g==,PuVsPDLBP/Yu8WHE2VIokBunqpDNDnof/CJmiyw6p94JsqsXUmFn0gIxTdu2Hes+Q9TJIV5ysDAhklEw7IRnNg==,es256,+presence"
      ];
      security.pam.services = {
        sudo.u2f.enable = true;
        sudo-i.u2f.enable = true;
        polkit-1.u2f.enable = true;
        cosmic-greeter.u2f.enable = true;
      };

      security.sudo.enable = false;
      security.sudo-rs = {
        enable = true;
        execWheelOnly = false;
      };

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
        nftables.enable = true;
        # Only what's used over the tailnet: SSH and Sunshine streaming (Moonlight).
        # The Sunshine web UI (47990) stays local.
        firewall.interfaces.tailscale0 = {
          allowedTCPPorts = [
            22
            47984
            47989
            48010
          ];
          allowedUDPPortRanges = [
            {
              from = 47998;
              to = 48000;
            }
          ];
          allowedUDPPorts = [
            48002
            48010
          ];
        };
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
        kernelPackages = pkgs.linuxPackages_zen;
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

        xdg.configFile."autostart/lock-on-login.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Lock on login
          NoDisplay=true
          Exec=${pkgs.writeShellScript "lock-on-login" ''
            for _ in 1 2 3 4 5; do
              ${pkgs.systemd}/bin/loginctl lock-session
              sleep 2
            done
          ''}
        '';

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
          hashedPasswordFile = config.sops.secrets.dfjay_password_hash.path;
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
