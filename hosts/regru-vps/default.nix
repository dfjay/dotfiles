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
      imports = [ ./storage.nix ];

      # Installed by nixos-infect; the layout lives in storage.nix until a reinstall
      vps.disko.enable = false;

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
