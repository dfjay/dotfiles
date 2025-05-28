{ pkgs, ... }:

{
  programs.java = {
    enable = true;
  };

  home.packages = with pkgs; [
    jmeter
    visualvm
    eclipse-mat
  ];
}
