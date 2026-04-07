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

# Convert a fresh Ubuntu VPS into NixOS, provision secrets and generate facter.json
# Usage: just infect linode-vps root@89.23.45.67
[group('vps')]
infect host target:
  #!/usr/bin/env bash
  set -euo pipefail
  ssh {{target}} 'hostnamectl set-hostname nixos'
  ssh {{target}} 'curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NO_REBOOT=1 NIX_CHANNEL=nixos-25.11 bash -x' || true
  ssh {{target}} 'grep -q forceInstall /etc/nixos/configuration.nix || sed -i "/boot.tmp.cleanOnBoot/a\  boot.loader.grub.forceInstall = true;" /etc/nixos/configuration.nix'
  ssh {{target}} 'curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-25.11 bash -x' || true
  echo "Waiting for reboot..."
  sleep 30
  until ssh -o ConnectTimeout=5 {{target}} true 2>/dev/null; do sleep 5; done
  just provision-keys {{host}} {{target}}
  just facter-remote {{host}} {{target}}

# Provision sops age key to a remote host
# Usage: just provision-keys linode-vps root@89.23.45.67
[group('vps')]
provision-keys host target:
  #!/usr/bin/env bash
  set -euo pipefail
  sops decrypt --extract '["age_key"]' "secrets/{{host}}.yaml" \
    | ssh {{target}} 'sudo mkdir -p /var/lib/sops-nix && sudo tee /var/lib/sops-nix/key.txt > /dev/null && sudo chmod 600 /var/lib/sops-nix/key.txt'
  echo "✓ age key provisioned on {{target}}"

# Generate facter.json from a remote host
# Usage: just facter-remote linode-vps root@89.23.45.67
[group('vps')]
facter-remote host target:
  ssh {{target}} 'nix --extra-experimental-features "nix-command flakes" run github:numtide/nixos-facter -- -o /tmp/facter.json'
  scp {{target}}:/tmp/facter.json hosts/{{host}}/facter.json
  echo "✓ hosts/{{host}}/facter.json updated"

# Deploy config to VPS via colmena and copy age key
# Usage: just deploy linode-vps
[group('vps')]
deploy host *args:
  #!/usr/bin/env bash
  set -euo pipefail
  colmena apply --on {{host}} {{args}}

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
