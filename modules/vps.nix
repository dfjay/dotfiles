{
  nixosModule =
    {
      config,
      lib,
      pkgs,
      inputs,
      hostname,
      username,
      userdesc,
      ...
    }:
    let
      cfg = config.vps;

      # Written by `just provision` (nixos-anywhere --generate-hardware-config)
      facterReport = ../hosts + "/${hostname}/facter.json";

      sizeOf =
        disk:
        lib.foldl' (acc: res: if res.type == "size" then res.value_1 * res.value_2 else acc) 0 (
          disk.resources or [ ]
        );

      stableName =
        disk:
        lib.findFirst (lib.hasPrefix "/dev/disk/by-id/") (lib.head disk.unix_device_names)
          disk.unix_device_names;

      disks = lib.filter (
        disk:
        !lib.any (
          name: lib.hasPrefix "/dev/zram" name || lib.hasPrefix "/dev/loop" name
        ) disk.unix_device_names
      ) (config.hardware.facter.report.hardware.disk or [ ]);

      # Linode attaches a separate swap disk, so take the largest one
      largestDisk = lib.foldl' (a: b: if sizeOf b > sizeOf a then b else a) (lib.head disks) disks;
    in
    {
      imports = [ inputs.princo.nixosModules.default ];

      options.vps = {
        disko.enable =
          lib.mkEnableOption "the disko disk layout, which nixos-anywhere uses to partition the disk"
          // {
            default = true;
          };

        disk = lib.mkOption {
          type = lib.types.str;
          default = if disks == [ ] then "/dev/sda" else stableName largestDisk;
          defaultText = lib.literalMD "the largest disk in the facter report";
          description = "Disk that disko partitions and installs GRUB to.";
        };
      };

      config = lib.mkMerge [
        {
          nixpkgs.overlays = [
            (_: prev: {
              inherit (inputs.nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system}) sing-box;
            })
          ];

          networking.hostName = hostname;

          hardware.facter.reportPath = lib.mkIf (builtins.pathExists facterReport) facterReport;

          # headless: the emulated QEMU vga would pull in mesa
          hardware.facter.detected.graphics.enable = false;

          sops.age.keyFile = "/var/lib/sops-nix/key.txt";
          sops.age.sshKeyPaths = [ ];

          security.acme.acceptTerms = true;

          # TCP BBR for better throughput
          boot.kernel.sysctl = {
            "net.core.default_qdisc" = "fq";
            "net.ipv4.tcp_congestion_control" = "bbr";
          };
          boot.kernelModules = [ "tcp_bbr" ];

          swapDevices = [
            {
              device = "/swapfile";
              size = 2048;
            }
          ];

          users = {
            defaultUserShell = pkgs.bash;
            mutableUsers = true;
            users.${username} = {
              isNormalUser = true;
              description = userdesc;
              extraGroups = [ "wheel" ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFmvdG0pEwUZcsrElS/5B+jR9PYfEECrtgy8VLs5pwR cardno:20_488_896"
              ];
            };
          };

          services.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = lib.mkForce "no";
              PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
              MaxAuthTries = 3;
              X11Forwarding = false;
              AllowAgentForwarding = false;
            };
          };

          services.fail2ban = {
            enable = true;
            maxretry = 3;
            bantime = "1h";
          };

          environment.systemPackages = with pkgs; [
            curl
            wget
            vim
            htop
            git
            mtr
            inetutils
            sysstat
            tcpdump
            jq
            dig
            wireguard-tools
            iperf3
            nmap
          ];

          security.sudo.enable = true;
        }

        # Boots on both BIOS and UEFI, so the layout fits any provider
        (lib.mkIf cfg.disko.enable {
          boot.loader.grub = {
            efiSupport = true;
            efiInstallAsRemovable = true;
          };

          boot.growPartition = true;
          fileSystems."/".autoResize = true;

          disko.devices.disk.main = {
            type = "disk";
            device = cfg.disk;
            content = {
              type = "gpt";
              partitions = {
                bios = {
                  size = "1M";
                  type = "EF02";
                };
                esp = {
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        })
      ];
    };
}
