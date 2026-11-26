{
  homeModule =
    { config, lib, ... }:

    {
      programs.yazi = {
        enable = true;
        settings = {
          mgr = {
            show_hidden = true;
            sort_dir_first = true;
          };
          open.prepend_rules = lib.mkIf (config.programs.nvf.enable or false) [
            {
              url = "*.{rs,go,nix,toml,yaml,yml,json,js,ts,py,lua,sh,md,txt}";
              use = "edit";
            }
          ];
        };
      };
    };
}
