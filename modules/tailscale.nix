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

      preservation.preserveAt."/persist".directories = lib.mkIf config.preservation.enable [
        "/var/lib/tailscale"
      ];
    };

  darwinModule =
    { ... }:
    {
      homebrew.casks = [ "tailscale-app" ];
    };
}
