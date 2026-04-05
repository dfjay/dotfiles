# Update all the flake inputs
[group('nix')]
up:
  nix flake update

# List all generations of the system profile
[group('nix')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Garbage collect all unused nix store entries
[group('nix')]
gc:
  nh clean all --keep-since 7d --keep 5

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
  ls -al /nix/var/nix/gcroots/auto/

# Bootstrap a fresh VPS into NixOS via nixos-anywhere
# Usage: just bootstrap yc-vps root@89.23.45.67
[group('vps')]
bootstrap host target:
  nix run github:nix-community/nixos-anywhere -- \
    --flake .#{{host}} \
    --generate-hardware-config nixos-facter hosts/{{host}}/facter.json \
    --target-host {{target}}

# Regenerate facter.json for the current host
# Usage: just facter dfjay-desktop
[group('nix')]
facter host:
  sudo nix run github:numtide/nixos-facter -- -o hosts/{{host}}/facter.json
  sudo chown $(id -u):$(id -g) hosts/{{host}}/facter.json
  @echo "✓ hosts/{{host}}/facter.json updated"

# Build OpenWrt sysupgrade image for GL-MT6000
[group('router')]
router-build:
  hosts/router/build.sh

# Deploy firmware to router via sysupgrade
[group('router')]
router-deploy:
  scp result/sysupgrade.bin root@192.168.1.1:/tmp/firmware.bin
  ssh root@192.168.1.1 'sysupgrade -n /tmp/firmware.bin'
