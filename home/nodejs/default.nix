{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_22
  ] ++ (with pkgs.nodePackages; [
    npm-check-updates
  ]);
}
