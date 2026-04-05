{ ... }:

{
  boot.loader.grub.device = "/dev/vda";

  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];
}
