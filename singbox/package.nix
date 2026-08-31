# sing-box 1.14.0 is not in nixpkgs yet: unstable and master are both still on
# 1.13.19 as of 2026-08-31, the day 1.14.0 was tagged. The configs in this
# directory use 1.14 syntax (`http_clients` / `http_client`), which 1.13
# rejects outright, so the binary has to move first.
#
# Delete this file and the `sing-box` overlays in hosts/*/default.nix once
# nixpkgs ships 1.14.
#
# Build tags are whatever nixpkgs uses. Upstream added with_cloudflared,
# with_usbip, with_openvpn and with_openconnect to its 1.14 defaults; none of
# them are used here, so the proven nixpkgs tag list is kept as-is.
{ fetchFromGitHub, sing-box }:
sing-box.overrideAttrs (_: {
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    tag = "v1.14.0";
    hash = "sha256-1v9bgM2H439ZoSkomv5dmT5SNrkuyOJ1iFFPlYPsW/k=";
  };

  vendorHash = "sha256-Bl73SkmnOyh5kULctDaxcOzXsYXRY2DOt80ME2+lBJo=";
})
