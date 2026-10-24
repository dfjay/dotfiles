{ ... }:

{
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

  fileSystems."/" = {
    device = "/dev/sda";
    fsType = "ext4";
  };

  # Linode networking — classic interface names, DHCP on eth0
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.tempAddresses = "disabled";
}
