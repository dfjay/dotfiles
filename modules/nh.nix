{
  nixosModule = {
    programs.nh = {
      enable = true;

      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 5";
      };
    };
  };

  darwinModule = {
    programs.nh = {
      enable = true;

      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };
    };
  };

  homeModule = {
    programs.nh.enable = true;
  };
}
