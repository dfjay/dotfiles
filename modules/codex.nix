{
  homeModule =
    { ... }:
    {
      programs.codex = {
        enable = true;
        enableMcpIntegration = true;
      };
    };
}
