{ ... }:

{
  boot.loader.grub.device = "/dev/vda";

  # TCP BBR for better throughput
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  boot.kernelModules = [ "tcp_bbr" ];

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
