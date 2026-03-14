{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = [ pkgs.nixd ];
    };
}
