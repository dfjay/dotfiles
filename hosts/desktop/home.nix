{ pkgs, username, ... }: 

{
  imports = [
    ../../home/bat
    ../../home/btop
    ../../home/common
    #../../home/dconf
    ../../home/eza
    ../../home/fastfetch
    ../../home/ghostty
    ../../home/git
    ../../home/go
    ../../home/gpg
    ../../home/gradle
    ../../home/helix
    ../../home/htop
    #../../home/hyprland
    ../../home/jdk
    ../../home/k8s
    ../../home/kitty
    ../../home/kotlin
    ../../home/lazydocker
    ../../home/lazygit
    #../../home/mako
    ../../home/nodejs
    ../../home/nushell
    ../../home/postgresql
    #../../home/rofi
    ../../home/skim
    ../../home/starship
    ../../home/translateshell
    ../../home/vscode
    #../../home/waybar
    ../../home/yazi
    ../../home/zed
    ../../home/zsh
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
    #nerd-fonts.mplus
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
