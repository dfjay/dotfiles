{ lib, ... }:

{
  # Gandi uses Xen with xvda virtual disk naming
  boot.loader.grub.device = lib.mkForce "/dev/xvda";

  # Explicitly force-load Xen block driver in initrd — necessary for Xen PV
  # guests to find /dev/xvda before mounting root
  boot.initrd.kernelModules = [ "xen_blkfront" ];

  # Serial console for Gandi's web terminal
  boot.consoleLogLevel = 7;
  boot.kernelParams = [ "console=ttyS0" ];

  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Restart = "always";
  };

  # TCP BBR for better throughput
  boot.kernel.sysctl = {
    "kernel.printk" = "4 4 1 7";
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  boot.kernelModules = [ "tcp_bbr" ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  # Required for IPv6 on GandiCloud
  networking.tempAddresses = "disabled";
}
