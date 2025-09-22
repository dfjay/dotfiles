{ username, ... }:

{
  imports = [
    ../../home/bat
    ../../home/erlang
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
    ../../home/js
    ../../home/nushell
    ../../home/postgresql
    ../../home/proto
    ../../home/python
    ../../home/rust
    ../../home/skim
    ../../home/ssh
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
