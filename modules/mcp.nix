{
  homeModule =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      sops.secrets.context7_api_key.sopsFile = ../secrets/personal.yaml;

      programs.mcp = {
        enable = true;
        servers = {
          context7 = {
            command = lib.getExe pkgs.context7-mcp;
            env.CONTEXT7_API_KEY.file = config.sops.secrets.context7_api_key.path;
          };
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          tableplus.command = "/Applications/TablePlus.app/Contents/MacOS/tableplus-mcp";
        };
      };
    };
}
