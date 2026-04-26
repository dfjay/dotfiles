{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        python314
        ruff
      ];

      programs.uv.enable = true;
    };
}
