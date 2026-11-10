{
  nixosModule =
    { ... }:

    {
      services.displayManager.noctalia-greeter.enable = true;

      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
    };

  homeModule =
    { ... }:

    {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
          shell.launch_apps_as_systemd_services = true;
        };
      };
    };
}
