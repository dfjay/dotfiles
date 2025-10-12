{ pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      bun
      nodejs_22
      typescript-language-server
    ]
    ++ (with pkgs.nodePackages; [
      npm-check-updates
      tsx
    ]);
}
