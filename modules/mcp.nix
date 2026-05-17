{
  homeModule =
    { ... }:
    {
      programs.mcp = {
        enable = true;
        servers = {
          playwright = {
            command = "npx";
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
