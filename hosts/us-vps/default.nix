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
    targetHost = "us-vps";
    targetUser = "dfjay";
  };

  config =
    { inputs, ... }:
    {
      # Pinned: the first install builds before facter.json is tracked
      vps.disk = "/dev/vda";

      # IPv4 over DHCP, IPv6 over SLAAC
      networking.useDHCP = true;
      networking.tempAddresses = "disabled";

      services.princo = {
        enable = true;
        config = [
          ../../vpn/princo.yaml
          "${inputs.vpn}/princo.yaml"
        ];
        node = "us";
        planPkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      };
    };
}
