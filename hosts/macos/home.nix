{ username, ... }:

{
  imports = [
    (import ../../modules/bat.nix).homeModule
    (import ../../modules/docker.nix).homeModule
    (import ../../modules/eza.nix).homeModule
    (import ../../modules/fastfetch.nix).homeModule
    (import ../../modules/formats.nix).homeModule
    (import ../../modules/git.nix).homeModule
    (import ../../modules/helix.nix).homeModule
    (import ../../modules/htop.nix).homeModule
    (import ../../modules/k8s.nix).homeModule
    (import ../../modules/kitty.nix).homeModule
    (import ../../modules/lazydocker.nix).homeModule
    (import ../../modules/lazygit.nix).homeModule
    (import ../../modules/nushell.nix).homeModule
    (import ../../modules/nvchad.nix).homeModule
    (import ../../modules/postgresql.nix).homeModule
    (import ../../modules/proto.nix).homeModule
    (import ../../modules/ripgrep.nix).homeModule
    (import ../../modules/skim.nix).homeModule
    (import ../../modules/ssh.nix).homeModule
    (import ../../modules/starship.nix).homeModule
    (import ../../modules/translateshell.nix).homeModule
    (import ../../modules/yazi.nix).homeModule
    (import ../../modules/zed.nix).homeModule
    (import ../../modules/zoxide.nix).homeModule
    (import ../../modules/zsh.nix).homeModule

    # Language modules
    (import ../../modules/languages/erlang.nix).homeModule
    (import ../../modules/languages/go.nix).homeModule
    (import ../../modules/languages/js.nix).homeModule
    (import ../../modules/languages/kotlin.nix).homeModule
    (import ../../modules/languages/python.nix).homeModule
    (import ../../modules/languages/rust.nix).homeModule
    (import ../../modules/languages/solidity.nix).homeModule
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
