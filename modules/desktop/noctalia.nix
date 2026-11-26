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
    in
    {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
          shell = {
            launch_apps_as_systemd_services = true;
            screenshot.directory = screenshots;
            window_switcher.mru = true;
          };
        };
      };

      home.activation.screenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "${screenshots}"
      '';
    };
}
