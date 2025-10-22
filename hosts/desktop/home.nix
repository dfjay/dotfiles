{ pkgs, username, ... }:

{
  imports = [
    (import ../../modules/bat.nix).homeModule
    (import ../../modules/btop.nix).homeModule
    (import ../../modules/eza.nix).homeModule
    (import ../../modules/fastfetch.nix).homeModule
    (import ../../modules/ghostty.nix).homeModule
    (import ../../modules/git.nix).homeModule
    (import ../../modules/gpg.nix).homeModule
    (import ../../modules/gradle.nix).homeModule
    (import ../../modules/helix.nix).homeModule
    (import ../../modules/k8s.nix).homeModule
    (import ../../modules/kitty.nix).homeModule
    (import ../../modules/lazydocker.nix).homeModule
    (import ../../modules/lazygit.nix).homeModule
    (import ../../modules/librewolf.nix).homeModule
    (import ../../modules/nvchad.nix).homeModule
    (import ../../modules/postgresql.nix).homeModule
    (import ../../modules/ripgrep.nix).homeModule
    (import ../../modules/skim.nix).homeModule
    (import ../../modules/starship.nix).homeModule
    (import ../../modules/translateshell.nix).homeModule
    (import ../../modules/vscode.nix).homeModule
    (import ../../modules/yazi.nix).homeModule
    (import ../../modules/zed.nix).homeModule
    (import ../../modules/zoxide.nix).homeModule
    (import ../../modules/zsh.nix).homeModule

    # Language modules
    (import ../../modules/languages/go.nix).homeModule
    (import ../../modules/languages/js.nix).homeModule
    (import ../../modules/languages/jdk.nix).homeModule
    (import ../../modules/languages/kotlin.nix).homeModule
    (import ../../modules/languages/rust.nix).homeModule
    (import ../../modules/languages/python.nix).homeModule
  ];

  news.display = "show";

  home = {
    username = username;
    homeDirectory = "/home/${username}";
  };

  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.noto
    nerd-fonts.hack
    nerd-fonts.ubuntu
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
