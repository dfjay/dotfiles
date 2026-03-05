{
  homeModule =
    { ... }:
    {
      programs.nix-index = {
        enable = true;
        enableZshIntegration = true;
      };
    };
}
