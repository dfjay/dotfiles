# Yandex Cloud VPS disk layout: BIOS-boot + ext4 root on /dev/vda (virtio).
# Not imported yet — used during next reprovisioning via `just bootstrap`.
{
  disko.devices.disk.main = {
    device = "/dev/vda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        # BIOS boot partition — Yandex Cloud VMs default to legacy BIOS
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
          };
        };
      };
    };
  };
}
