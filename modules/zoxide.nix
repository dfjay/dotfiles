{
  homeModule =
    { ... }:

    {
      programs.zoxide = {
        enable = true;
        options = [ "--cmd" "cd" ];
      };
    };
}
