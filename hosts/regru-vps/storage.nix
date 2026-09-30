{ ... }:

{
  # REG.RU cloud image: GPT with a BIOS boot partition, legacy boot
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    forceInstall = true;
  };

  # TCP BBR for better throughput
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  boot.kernelModules = [ "tcp_bbr" ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/cloudimg-rootfs";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "ext4";
  };

  # 1 GB RAM: zram plus a swapfile so on-target builds don't OOM
  zramSwap.enable = true;
  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  # OpenStack 1:1 NAT, private address via DHCP on ens3; no IPv6
  networking.useDHCP = true;
}
