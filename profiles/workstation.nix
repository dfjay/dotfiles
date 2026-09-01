{ modules, profiles, ... }:

profiles.base
++ (with modules; [
  # system
  firewall
  stylix

  # tools
  beam
  claude
  direnv
  docker
  fd
  fish
  formats
  gh
  ghostty
  git
  go
  gpg
  js
  just
  jvm
  k8s
  lazydocker
  lazygit
  librewolf
  mcp
  nh
  nix
  nix-index
  nushell
  postgres
  python
  ripgrep-all
  rust
  skills
  skim
  ssh
  tealdeer
  yubikey
  zed
])
