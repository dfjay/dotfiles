{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        python315
        ruff
      ];

      programs.uv.enable = true;
    };
}
