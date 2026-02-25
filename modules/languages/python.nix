{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        (pkgs.python314.withPackages (ps: [
          ps.pip
          ps.pyyaml
          ps.pandas
          ps.requests
        ]))
      ];

      programs.uv.enable = true;
    };
}
