{ pkgs, ... }:

{
  programs.java = {
    enable = true;
  };

  home.packages = with pkgs; [
    visualvm
    eclipse-mat
  ];
}
