{
  homeModule =
    { ... }:

    {
      programs.ripgrep-all = {
        enable = true;
      };

      home.shellAliases = {
        rg = "rga";
      };
    };
}
