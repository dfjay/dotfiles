{ ... }:

{
  # Disk layout — activated during `just bootstrap linode-vps root@<ip>`
  disko.devices.disk.main = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        # BIOS boot partition — Linode boots via BIOS (serial console via LISH)
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

  # Bootloader — Linode uses BIOS with serial console (LISH).
  # disko.nix configures boot.loader.grub.devices automatically;
  # we only override the serial console settings here.
  boot.loader.grub = {
    enable = true;
    forceInstall = true;
    extraConfig = ''
      serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
      terminal_input serial;
      terminal_output serial;
    '';
  };
  boot.loader.timeout = 10;
  boot.kernelParams = [ "console=ttyS0,19200n8" ];

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

  # Linode networking — classic interface names, DHCP on eth0
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
}
