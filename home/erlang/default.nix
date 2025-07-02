{ pkgs, ... }:

{
  home.packages = with pkgs.beam27Packages; [
    erlang
    elixir
  ];
}
