#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Decrypting router secrets..."
export ROUTER_WIFI_KEY=$(sops -d --extract '["router_wifi_key"]' "$REPO_ROOT/secrets/secret.yaml")
export ROUTER_PPPOE_USER=$(sops -d --extract '["router_pppoe_user"]' "$REPO_ROOT/secrets/secret.yaml")
export ROUTER_PPPOE_PASS=$(sops -d --extract '["router_pppoe_pass"]' "$REPO_ROOT/secrets/secret.yaml")

echo "Rendering the sing-box profile of the router user..."
VPN_REPO=$(nix flake archive --json "$REPO_ROOT" | jq -r .inputs.vpn.path)
export ROUTER_SING_BOX_CONFIG=$(
  nix run --inputs-from "$REPO_ROOT" princo -- \
    -c "$REPO_ROOT/vpn/princo.yaml" -c "$VPN_REPO/princo.yaml" render --user router --platform linux
)

echo "Building OpenWrt image..."
nix build "$REPO_ROOT#openwrt-image" --impure "$@"

echo "Done: $(readlink -f result)/sysupgrade.bin"
