{
  homeModule =
    { ... }:

    {
      programs.lazygit = {
        enable = true;
        settings = {
          git.diffRenderers = [
            {
              colorArg = "always";
              command = "delta --paging=never";
            }
          ];
        };
      };
    };
}
