{
  nixosModule =
    { config, lib, ... }:

    {
      services.displayManager.noctalia-greeter.enable = true;

      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;

      preservation.preserveAt."/persist".directories = lib.mkIf config.preservation.enable [
        "/var/lib/power-profiles-daemon"
        {
          directory = "/var/lib/noctalia-greeter";
          user = "greeter";
          group = "greeter";
          mode = "0750";
        }
      ];
    };

  homeModule =
    { config, lib, ... }:

    let
      screenshots = "${config.home.homeDirectory}/Pictures/Screenshots";
      wallpapers = "${config.home.homeDirectory}/Pictures/Wallpapers";
    in
    {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
          bar.default = {
            thickness = 30;
            margin_ends = 0;
            radius = 0;
            concave_edge_corners = false;
            background_opacity = 0.7;
            shadow = false;
            monitor.touchscreen = {
              match = "SU13TO";
              enabled = false;
            };
            start = [
              "launcher"
              "wallpaper"
              "workspaces"
            ];
            end = [
              "media"
              "tray"
              "notifications"
              "clipboard"
              "network"
              "bluetooth"
              "volume"
              "control-center"
              "session"
            ];
          };
          wallpaper.directory = wallpapers;
          shell = {
            launch_apps_as_systemd_services = true;
            screenshot.directory = screenshots;
            window_switcher.mru = true;
          };
        };
      };

      home.activation.picturesDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "${screenshots}" "${wallpapers}"
      '';
    };
}
