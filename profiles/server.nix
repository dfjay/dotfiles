{ modules, profiles, ... }:

profiles.base
++ (with modules; [
  locale

  git
  terminfo
  tmux
])
