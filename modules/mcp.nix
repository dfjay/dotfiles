{
  homeModule =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      sops.secrets.context7_api_key = { };

      programs.mcp = {
        enable = true;
        servers = {
          playwright = {
            command = lib.getExe' pkgs.nodejs_24 "npx";
            args = [
              "@playwright/mcp@latest"
              "--browser"
              "chromium"
            ];
          };
          context7 = {
            command = lib.getExe' pkgs.nodejs_24 "npx";
            args = [ "@upstash/context7-mcp@latest" ];
            env.CONTEXT7_API_KEY.file = config.sops.secrets.context7_api_key.path;
          };
        };
      };
    };
}
