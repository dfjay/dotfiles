{ pkgs, ... }:

{
  programs.go = {
    enable = true;
  };

  home.packages = with pkgs; [
      golangci-lint
      go-migrate
      gosec
  ];
}
