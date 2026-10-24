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
    targetHost = "gandi-vps";
    targetUser = "dfjay";
  };

  config =
    { inputs, ... }:
    {
      imports = [ ./storage.nix ];

      services.princo = {
        enable = true;
        config = ../../vpn/princo.yaml;
        node = "fr";
        planPkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      };

      services.nginx.virtualHosts."dfjay.com" = {
        forceSSL = true;
        enableACME = true;
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
          {
            addr = "[::]";
            port = 80;
          }
          {
            addr = "127.0.0.1";
            port = 8443;
            ssl = true;
          }
          {
            addr = "[::1]";
            port = 8443;
            ssl = true;
          }
        ];
        root = "${inputs.portfolio}";
        locations."/".tryFiles = "$uri $uri/ /index.html";
      };
    };
}
