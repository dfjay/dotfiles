{
  homeModule =
    { ... }:

    {
      programs.gpg.enable = true;
      services.gpg-agent.enable = true;
      services.gpg-agent.enableSshSupport = true;
    };

  nixosModule =
    { ... }:
    {
      systemd.user.services.gcr-ssh-agent.enable = false;
      systemd.user.sockets.gcr-ssh-agent.enable = false;
    };

  darwinModule =
    { ... }:
    {
      environment.variables.SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
      homebrew.casks = [
        "gpg-suite"
      ];
    };
}
