{
  nixosModule =
    { ... }:

    {
      services.desktopManager.cosmic = {
        enable = true;
      };

      services.displayManager.cosmic-greeter = {
        enable = true;
      };

      programs.kdeconnect.enable = true;
    };

  homeModule =
    { pkgs, ... }:

    {
      services.gpg-agent.pinentry.package = pkgs.pinentry-qt;
    };
}
