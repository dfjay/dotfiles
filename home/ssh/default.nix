{ ... }:

{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    includes = [
      "~/.colima/ssh_config"
      "~/.orbstack/ssh"
    ];
  };
}
