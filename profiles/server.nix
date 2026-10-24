{ modules, profiles, ... }:

profiles.base
++ (with modules; [
  colmena-target
  locale
  tailscale-server
  vps

  git
  terminfo
  tmux
])
