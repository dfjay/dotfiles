{
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    forceInstall = true;
    extraConfig = ''
      serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
      terminal_input serial;
      terminal_output serial;
    '';
  };
  boot.loader.timeout = 10;

  boot.kernelParams = [ "console=ttyS0,19200n8" ];

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  boot.kernelModules = [ "tcp_bbr" ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [ "nvme" ];

  fileSystems."/" = {
    device = "/dev/sda";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/sdb"; }
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  # Linode networking
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
