{
  nixosModule =
    { pkgs, ... }:

    {
      services.displayManager.gdm = {
        enable = true;
      };

      services.desktopManager.gnome = {
        enable = true;
      };

      programs.kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };

      environment.systemPackages = with pkgs.gnomeExtensions; [
        blur-my-shell
      ];
    };
}
