{
  nixosModule =
    { ... }:
    {
      networking.firewall = {
        # mDNS for printer/device discovery on LAN
        allowedUDPPorts = [ 5353 ];
      };
    };

  darwinModule =
    { ... }:
    {
      networking.applicationFirewall = {
        enable = true;
        blockAllIncoming = false;
        allowSigned = true;
        allowSignedApp = true;
        enableStealthMode = true;
      };
    };
}
