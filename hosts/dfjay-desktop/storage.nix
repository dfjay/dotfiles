{ ... }:

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            type = "EF00";
            size = "1G";
            priority = 1;
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
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              settings.bypassWorkqueues = true;
              settings.crypttabExtraOpts = [ "tpm2-device=auto" ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;

  boot.initrd.systemd.services.rollback = {
    description = "Rollback BTRFS root subvolume to a pristine state";
    wantedBy = [ "initrd.target" ];
    requires = [ "systemd-cryptsetup@cryptroot.service" ];
    after = [ "systemd-cryptsetup@cryptroot.service" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /btrfs_tmp
      mount -t btrfs -o subvol=/ /dev/mapper/cryptroot /btrfs_tmp

      if [[ -e /btrfs_tmp/@root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@root)" "+%Y-%m-%d_%H:%M:%S")
          mv /btrfs_tmp/@root "/btrfs_tmp/old_roots/$timestamp"
      fi

      find /btrfs_tmp/old_roots/ -mindepth 1 -maxdepth 1 -mtime +30 \
        -exec btrfs subvolume delete --recursive {} +

      btrfs subvolume create /btrfs_tmp/@root
      umount /btrfs_tmp
    '';
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        "/var/log"
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        {
          directory = "/var/lib/userborn";
          inInitrd = true;
        }
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/var/lib/systemd/rfkill"
        {
          directory = "/var/lib/systemd/timesync";
          user = "systemd-timesync";
          group = "systemd-timesync";
        }
        "/var/lib/cups"
        "/var/lib/sbctl"
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/var/lib/AccountsService"
        "/var/lib/NetworkManager"
        "/var/lib/sudo"
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "0750";
        }
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/var/lib/systemd/random-seed";
          mode = "0600";
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key.pub";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key.pub";
          how = "symlink";
          configureParent = true;
        }
      ];
    };
  };
}
