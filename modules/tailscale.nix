{
  nixosModule =
    { config, lib, ... }:
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        extraUpFlags = [
          "--reset"
          "--hostname"
          config.networking.hostName
        ];
      };

      services.resolved.enable = true;
      security.polkit.enable = lib.mkIf config.networking.dhcpcd.enable true;
    };

  darwinModule =
    { ... }:
    {
      homebrew.casks = [ "tailscale-app" ];
    };
}
