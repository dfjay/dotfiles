{
  nixosModule =
    { ... }:

    {
      services.displayManager.noctalia-greeter.enable = true;

      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
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
