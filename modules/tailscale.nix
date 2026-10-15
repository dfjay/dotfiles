{
  nixosModule =
    { config, lib, ... }:
    {
      sops.secrets.tailscale_authkey = {
        sopsFile = ../secrets/shared.yaml;
      };

      services.tailscale = {
        enable = true;
        openFirewall = true;
        authKeyFile = config.sops.secrets.tailscale_authkey.path;
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
