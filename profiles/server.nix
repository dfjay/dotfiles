{ modules, profiles, ... }:

profiles.base
++ (with modules; [
  colmena-target
  locale

  git
  terminfo
  tmux
])
