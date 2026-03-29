{
  nixosModule =
    { ... }:
    {
    };

  homeModule =
    { ... }:
    {
      programs.nushell = {
        enable = true;
      };
    };
}
