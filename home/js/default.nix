{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_22
    bun
  ] ++ (with pkgs.nodePackages; [
    npm-check-updates
    tsx
  ]);
}
