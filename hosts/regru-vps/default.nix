{ profiles, ... }:

{
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  userdesc = "Pavel Yozhikov";
  nixpkgs = "nixpkgs-stable";
  home-manager = "home-manager-stable";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  modules = profiles.server;

  colmena = {
    targetHost = "regru-vps";
    targetUser = "dfjay";
  };

  config =
    { inputs, ... }:
    {
      zramSwap.enable = true;

      # OpenStack 1:1 NAT, private address via DHCP on ens3; no IPv6
      networking.useDHCP = true;

      services.princo = {
        enable = true;
        config = ../../vpn/princo.yaml;
        node = "ru";
        planPkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      };

      services.resolved.settings.Resolve.FallbackDNS = [
        "194.58.125.120"
        "194.67.94.40"
      ];
    };
}
