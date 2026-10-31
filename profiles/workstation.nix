{ modules, profiles, ... }:

profiles.base
++ (with modules; [
  # system
  firewall
  stylix

  # tools
  claude
  direnv
  docker
  fd
  fish
  formats
  fzf
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
  nix
  nix-index
  nushell
  postgres
  python
  ripgrep-all
  rust
  skills
  ssh
  tealdeer
  yubikey
  zed
])
