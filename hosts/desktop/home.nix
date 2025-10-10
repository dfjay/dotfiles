{ pkgs, username, ... }: 

{
  imports = [
    ../../home/bat.nix
    ../../home/btop.nix
    ../../home/eza.nix
    ../../home/fastfetch.nix
    ../../home/ghostty.nix
    ../../home/git.nix
    ../../home/go.nix
    ../../home/gpg.nix
    ../../home/gradle.nix
    ../../home/helix.nix
    ../../home/jdk.nix
    ../../home/k8s.nix
    ../../home/kitty.nix
    ../../home/kotlin.nix
    ../../home/lazydocker.nix
    ../../home/lazygit.nix
    ../../home/librewolf.nix
    ../../home/jdk.nix
    ../../home/js.nix
    ../../home/postgresql.nix
    ../../home/ripgrep.nix
    ../../home/rust.nix
    ../../home/skim.nix
    ../../home/starship.nix
    ../../home/translateshell.nix
    ../../home/vscode.nix
    ../../home/yazi.nix
    ../../home/zed.nix
    ../../home/zoxide.nix
    ../../home/zsh.nix
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
