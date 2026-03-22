{
  homeModule =
    { ... }:

    {
      programs.btop = {
        enable = true;
      };

      home.shellAliases = {
        top = "btop";
      };
    };
}
