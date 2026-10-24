{ profiles, ... }:

{
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  userdesc = "Pavel Yozhikov";
  nixpkgs = "nixpkgs-stable";
  home-manager = "home-manager-stable";
  nixosStateVersion = "25.11";
  homeStateVersion = "25.11";

  modules = profiles.server;

  colmena = {
    targetHost = "linode-vps";
    targetUser = "dfjay";
  };

  config =
    { inputs, ... }:
    {
      imports = [ ./storage.nix ];

      # Installed by nixos-infect; the layout lives in storage.nix until a reinstall
      vps.disko.enable = false;

      services.princo = {
        enable = true;
        config = ../../vpn/princo.yaml;
        node = "us";
        planPkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      };
    };
}
