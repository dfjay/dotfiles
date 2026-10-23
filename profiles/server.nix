{ modules, profiles, ... }:

profiles.base
++ (with modules; [
  colmena-target
  locale
  tailscale-server

  git
  terminfo
  tmux
])
