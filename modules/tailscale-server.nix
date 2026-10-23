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
          "--advertise-tags=tag:server"
        ];
      };
    };
}
