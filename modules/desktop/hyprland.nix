{
  nixosModule =
    { ... }:

    {
      programs.hyprland.enable = true;

      services.gnome.gnome-keyring.enable = true;
    };

  homeModule =
    { lib, pkgs, ... }:

    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;

        configType = "lua";
        systemd.enableXdgAutostart = true;

        extraLuaFiles = {
          nix = {
            autoLoad = false;
            content = ''
              return {
                terminal = "${lib.getExe pkgs.ghostty}",
                noctalia = "${lib.getExe pkgs.noctalia}",
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
