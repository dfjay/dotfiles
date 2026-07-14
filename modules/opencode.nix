{
  homeModule =
    { ... }:
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
      };
    };
}
