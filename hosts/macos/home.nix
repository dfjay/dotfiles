{ username, ... }:

{
  imports = [
    ../../home/bat.nix
    ../../home/erlang.nix
    ../../home/eza.nix
    ../../home/fastfetch.nix
    ../../home/git.nix
    ../../home/go.nix
    ../../home/helix.nix
    ../../home/htop.nix
    ../../home/k8s.nix
    ../../home/kitty.nix
    ../../home/kotlin.nix
    ../../home/lazydocker.nix
    ../../home/lazygit.nix
    ../../home/js.nix
    ../../home/nushell.nix
    ../../home/postgresql.nix
    ../../home/proto.nix
    ../../home/python.nix
    ../../home/ripgrep.nix
    ../../home/rust.nix
    ../../home/skim.nix
    ../../home/ssh.nix
    ../../home/starship.nix
    ../../home/translateshell.nix
    ../../home/vscode.nix
    ../../home/yazi.nix
    ../../home/zed.nix
    ../../home/zoxide.nix
    ../../home/zsh.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
