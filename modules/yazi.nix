{
  homeModule =
    { ... }:

    {
      programs.yazi = {
        enable = true;
        settings = {
          mgr = {
            show_hidden = true;
            sort_dir_first = true;
          };
          opener = {
            edit = [
              {
                run = ''hx "%s"'';
                block = true;
                desc = "Open in Helix";
              }
            ];
          };
          open.prepend_rules = [
            {
              url = "*.{rs,go,nix,toml,yaml,yml,json,js,ts,py,lua,sh,md,txt}";
              use = "edit";
            }
          ];
        };
      };
    };
}
