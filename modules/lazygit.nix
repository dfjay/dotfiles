{
  homeModule =
    { ... }:

    {
      programs.lazygit = {
        enable = true;
        settings = {
          git.pagers = [
            {
              colorArg = "always";
              pager = "delta --paging=never";
            }
          ];
        };
      };
    };
}
