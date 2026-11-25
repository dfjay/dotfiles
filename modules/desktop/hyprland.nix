{
  nixosModule =
    { ... }:

    {
      programs.hyprland.enable = true;

      services.gnome.gnome-keyring.enable = true;

      # Terminal=true entries (yazi as the folder handler) need it to start.
      xdg.terminal-exec = {
        enable = true;
        settings.default = [ "com.mitchellh.ghostty.desktop" ];
      };
    };

  homeModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;

        configType = "lua";
        systemd = {
          enableXdgAutostart = true;
          # noctalia launches apps as systemd services, they need the cursor too.
          variables = [
            "DISPLAY"
            "HYPRLAND_INSTANCE_SIGNATURE"
            "WAYLAND_DISPLAY"
            "XDG_CURRENT_DESKTOP"
            "XDG_SESSION_TYPE"
            "XCURSOR_THEME"
            "XCURSOR_SIZE"
          ];
        };

        extraLuaFiles = {
          nix = {
            autoLoad = false;
            content = ''
              return {
                terminal = "${lib.getExe pkgs.ghostty}",
                noctalia = "${lib.getExe pkgs.noctalia}",
                cursor = {
                  name = "${config.home.pointerCursor.name}",
                  size = "${toString config.home.pointerCursor.size}",
                },
              }
            '';
          };
          main = ./hyprland.lua;
        };
      };

      wayland.systemd.target = "hyprland-session.target";

      services.hyprpolkitagent.enable = true;

      services.hypridle = {
        enable = true;
        settings.general.before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
      };

      services.gpg-agent.pinentry.package = pkgs.pinentry-qt;
    };
}
