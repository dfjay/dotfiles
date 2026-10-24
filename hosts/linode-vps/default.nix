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
    targetHost = "linode-vps";
    targetUser = "dfjay";
  };

  config =
    { inputs, ... }:
    {
      imports = [ ./storage.nix ];

      services.princo = {
        enable = true;
        config = ../../vpn/princo.yaml;
        node = "us";
        planPkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      };
    };
}
