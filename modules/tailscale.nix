{
  nixosModule =
    { config, ... }:
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
    };

  darwinModule =
    { ... }:
    {
      homebrew.casks = [ "tailscale-app" ];
    };
}
