{
  nixosModule =
    { config, ... }:
    {
      sops.secrets.tailscale_authkey = {
        sopsFile = ../secrets/shared.yaml;
      };

      services.tailscale = {
        authKeyFile = config.sops.secrets.tailscale_authkey.path;
        authKeyParameters = {
          ephemeral = false;
          preauthorized = true;
        };
        extraUpFlags = [
          "--reset"
          "--hostname"
          config.networking.hostName
          "--advertise-tags=tag:server"
        ];
      };

      systemd.services.tailscaled-autoconnect = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
}
