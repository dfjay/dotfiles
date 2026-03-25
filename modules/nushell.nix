{
  nixosModule =
    { ... }:
    {
      programs.nushell.enable = true;
    };

  homeModule =
    { ... }:
    {
      programs.nushell = {
        enable = true;
      };
    };
}
