{
  homeModule =
    { pkgs, lib, ... }:
    {
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
        };
      };
    };
}
