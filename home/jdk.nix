{ pkgs, ... }:

{
  programs.java = {
    enable = true;
  };

  home.packages = with pkgs; [
    eclipse-mat
    keystore-explorer
    visualvm
  ];
}
