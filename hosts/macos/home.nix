{ username, ... }:

{
  imports = [
    ../../home/bat
    ../../home/common
    ../../home/eza
    ../../home/fastfetch
    ../../home/firefox
    #../../home/ghostty
    ../../home/git
    ../../home/go
    ../../home/helix
    ../../home/htop
    ../../home/k8s
    ../../home/kitty
    ../../home/kotlin
    ../../home/lazydocker
    ../../home/lazygit
    ../../home/librewolf
    ../../home/nodejs
    ../../home/nushell
    ../../home/postgresql
    ../../home/python
    ../../home/skim
    ../../home/starship
    ../../home/translateshell
    ../../home/vscode
    ../../home/yazi
    ../../home/zed
    ../../home/zsh
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
