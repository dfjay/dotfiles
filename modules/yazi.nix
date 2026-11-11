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
          opener = lib.mkIf (config.programs.nvf.enable or false) {
            edit = [
              {
                run = ''nvim "%s"'';
                block = true;
                desc = "Open in Neovim";
              }
            ];
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
