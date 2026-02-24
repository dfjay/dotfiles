{
  homeModule =
    { pkgs, lib, ... }:

    {
      programs.zellij = {
        enable = true;
        enableZshIntegration = false;

        layouts.dev = ''
          layout {
            default_tab_template {
              pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
              }
              children
              pane size=2 borderless=true {
                plugin location="zellij:status-bar"
              }
            }

            tab name="edit" focus=true {
              pane split_direction="vertical" {
                pane size="20%" command="bash" {
                  args "-c" "YAZI_CONFIG_HOME=$HOME/.config/yazi-sidebar exec yazi"
                }
                pane command="hx"
              }
            }

            tab name="git" {
              pane command="lazygit"
            }
          }
        '';
      };

      xdg.configFile."yazi-sidebar/yazi.toml".source =
        (pkgs.formats.toml { }).generate "yazi-sidebar-config"
          {
            mgr = {
              show_hidden = true;
              sort_dir_first = true;
              ratio = [
                0
                1
                0
              ];
            };
            opener.edit = [
              {
                run = ''zellij action focus-next-pane && zellij action write 27 && sleep 0.05 && zellij action write-chars ":open %s" && zellij action write 13 && zellij action focus-previous-pane'';
                desc = "Open in Helix";
              }
            ];
            open.prepend_rules = [
              {
                url = "*.{rs,go,nix,toml,yaml,yml,json,js,ts,py,lua,sh,md,txt}";
                use = "edit";
              }
            ];
          };
    };
}
