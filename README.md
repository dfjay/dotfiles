# dotfiles

Nix flake configuration for my machines.

## Hosts

| Host | Platform | Description |
|------|----------|-------------|
| `dfjay-laptop` | aarch64-darwin | MacBook Pro (nix-darwin) |
| `dfjay-desktop` | x86_64-linux | NixOS desktop (COSMIC DE) |
| `vps` | x86_64-linux | NixOS VPS (nginx, sing-box, WARP) |

## Stack

- **[Nix Flakes](https://nixos.wiki/wiki/Flakes)** + **[flake-parts](https://github.com/hercules-ci/flake-parts)** — reproducible builds
- **[home-manager](https://github.com/nix-community/home-manager)** — user environment & dotfiles
- **[nix-darwin](https://github.com/LnL7/nix-darwin)** — macOS system configuration
- **[Stylix](https://github.com/danth/stylix)** — system-wide theming
- **[sops-nix](https://github.com/Mic92/sops-nix)** — secrets management (Age + PGP/YubiKey)
- **[Colmena](https://github.com/zhaofengli/colmena)** — remote deployment
- **[Lanzaboote](https://github.com/nix-community/lanzaboote)** — Secure Boot
- **[Disko](https://github.com/nix-community/disko)** — declarative disk partitioning

## Structure

```
.
├── flake.nix          # Flake entrypoint
├── hosts/             # Per-machine configurations
│   ├── dfjay-laptop/  # macOS
│   ├── dfjay-desktop/ # NixOS desktop
│   └── vps/           # NixOS server
├── modules/           # Reusable NixOS/home-manager modules
│   ├── de/            # Desktop environments (COSMIC, GNOME, KDE)
│   ├── languages/     # Dev toolchains (Go, Rust, Python, JS, ...)
│   ├── shell/         # Shell configs (Zsh, Nushell, Fish)
│   └── *.nix          # Individual tool modules
├── secrets/           # SOPS-encrypted secrets
└── Justfile           # Common tasks
```

## Usage

```bash
# Update flake inputs
just up

# Apply configuration (macOS)
sudo darwin-rebuild switch --flake .

# Apply configuration (NixOS)
sudo nixos-rebuild switch --flake .

# Deploy to remote host
colmena apply

# Garbage collect old generations
just gc
```

## License

[MIT](LICENSE)
