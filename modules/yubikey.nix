{
  homeModule =
    { ... }:
    {
      programs.git.signing = {
        key = "A82705DF08BC95859FF5CB7E577260D68251AC22"; # primary key [SC]
        signByDefault = true;
      };

      services.gpg-agent.sshKeys = [
        "FB20142EEBEAA96FD7F688382F5E558BA4A23694" # auth subkey
      ];
    };
}
