{ username, ... }:

{
  imports = [
    ../../home/bat.nix
    ../../home/eza.nix
    ../../home/fastfetch.nix
    ../../home/git.nix
    ../../home/helix.nix
    ../../home/htop.nix
    ../../home/k8s.nix
    ../../home/kitty.nix
    ../../home/kotlin.nix
    ../../home/lazydocker.nix
    ../../home/lazygit.nix
    ../../home/nushell.nix
    ../../home/nvchad.nix
    ../../home/postgresql.nix
    ../../home/proto.nix
    ../../home/ripgrep.nix
    ../../home/skim.nix
    ../../home/ssh.nix
    ../../home/starship.nix
    ../../home/translateshell.nix
    ../../home/vscode.nix
    ../../home/yazi.nix
    ../../home/zed.nix
    ../../home/zoxide.nix
    ../../home/zsh.nix

    ../../home/languages/erlang.nix
    ../../home/languages/go.nix
    ../../home/languages/js.nix
    ../../home/languages/python.nix
    ../../home/languages/rust.nix
    ../../home/languages/solidity.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
