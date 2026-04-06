# Gandi VPS disk layout: BIOS-boot + ext4 root labelled "nixos" on /dev/xvda (Xen PV).
# Not imported yet — used during next reprovisioning via `just bootstrap`.
{
  disko.devices.disk.main = {
    device = "/dev/xvda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        # BIOS boot partition — Gandi's Xen bootloader (pvgrub/hvm) loads via BIOS
        bios = {
          size = "1M";
          type = "EF02";
          priority = 0;
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            # Label matches storage.nix fileSystems."/" device reference
            extraArgs = [ "-L" "nixos" ];
          };
        };
      };
    };
  };
}
