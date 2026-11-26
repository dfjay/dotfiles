{
  homeModule =
    { pkgs, ... }:

    {
      programs.gpg.enable = true;
      services.gpg-agent.enable = true;
      services.gpg-agent.enableSshSupport = true;

      home.packages = with pkgs; [
        gopass
        gpg-tui
      ];
    };

  nixosModule =
    { ... }:
    {
      services.gnome.gcr-ssh-agent.enable = false;
    };
}
