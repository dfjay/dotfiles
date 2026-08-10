# dotfiles

Nix flake configuration for my machines.

## Hosts

| Host | Platform | Description |
|------|----------|-------------|
| `dfjay-laptop` | aarch64-darwin | macOS (nix-darwin) |
| `dfjay-desktop` | x86_64-linux | NixOS desktop |
| `gandi-vps` | x86_64-linux | NixOS VPS |
| `linode-vps` | x86_64-linux | NixOS VPS |
| `router` | mediatek/filogic | OpenWrt router |

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
├── lib.nix            # Module and profile collection
├── hosts/
│   ├── default.nix    # Host discovery, colmena nodes
│   ├── mk-host.nix    # Host declaration -> nixos/darwin configuration
│   ├── dfjay-laptop/  # macOS
│   ├── dfjay-desktop/ # NixOS desktop
│   ├── gandi-vps/     # NixOS VPS
│   ├── linode-vps/    # NixOS VPS
│   └── router/        # OpenWrt router
├── profiles/          # Named module lists shared by hosts
│   ├── base.nix       # Every host, servers included
│   ├── server.nix     # Headless boxes
│   └── workstation.nix
├── modules/           # Reusable NixOS/darwin/home-manager modules
│   ├── de/            # Desktop environments
│   └── *.nix          # Individual tool modules
├── singbox/           # sing-box VPN stack
├── overlays/          # nixpkgs overlays
├── secrets/           # SOPS-encrypted secrets
└── justfile           # Common tasks
```

### Adding a host

Create `hosts/<name>/default.nix` — nothing else needs to be touched. The
directory name is the host name, `system` decides whether a `nixosConfiguration`
or a `darwinConfiguration` is generated, and adding a `colmena` attribute makes
the host deployable:

```nix
{ modules, profiles, ... }:

{
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  nixosStateVersion = "25.11";
  homeStateVersion = "25.11";

  modules = profiles.server ++ (with modules; [ docker ]);

  colmena = {
    targetHost = "<name>";
    targetUser = "dfjay";
  };

  config = { ... }: { /* host-specific configuration */ };
}
```

A host directory containing a `flake-module.nix` is left alone and imported as a
flake-parts module instead — that is how `router/` opts out of the above.

### Modules

Every file in `modules/` returns a bundle of per-class modules:

```nix
{
  nixosModule = { ... }: { /* ... */ };
  darwinModule = { ... }: { /* ... */ };
  homeModule = { ... }: { /* ... */ };
}
```

They are published as `flake.modules.<class>.<name>`, where `<class>` is
`nixos`, `darwin` or `homeManager` and `<name>` is the path under `modules/`
with `/` replaced by `-` (`modules/de/kde.nix` becomes `de-kde`). Hosts and
profiles list names, which `mk-host.nix` resolves against that namespace and
filters by the host's platform — so a single list covers all three classes.

Because the namespace is the flake-parts `flake.modules` option, any other file
can extend a module by defining into the same name, and a name that has nothing
for a host's platform is an error rather than a silent no-op.

## Usage

```bash
# Update flake inputs
just up

# Apply configuration (macOS)
nh darwin switch .

# Apply configuration (NixOS)
nh os switch .

# Deploy to remote host
colmena apply

# Build OpenWrt image
hosts/router/build.sh

# Garbage collect old generations
just gc
```

## License

[MIT](LICENSE)
