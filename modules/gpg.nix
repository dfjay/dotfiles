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
      systemd.user.services.gcr-ssh-agent.enable = false;
      systemd.user.sockets.gcr-ssh-agent.enable = false;
    };
}
