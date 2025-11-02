{ inputs, ... }:
{
  flake.nixosConfigurations = {
    dfjay-desktop =
      let
        username = "dfjay";
        useremail = "mail@dfjay.com";
        hostname = "dfjay-desktop";
        userdesc = "Pavel Yozhikov";

        specialArgs = inputs // {
          inherit
            inputs
            username
            useremail
            hostname
            userdesc
            ;
        };
      in
      inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          (
            {
              pkgs,
              lib,
              ...
            }:
            {
              nixpkgs.overlays = [ inputs.nix-vscode-extensions.overlays.default ];
            }
          )
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.stylix.nixosModules.stylix
          inputs.disko.nixosModules.disko
          inputs.preservation.nixosModules.preservation
          inputs.sops-nix.nixosModules.sops
          ../../hosts/desktop

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [ inputs.nix4nvchad.homeManagerModules.default ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username} = import ../../hosts/desktop/home.nix;
          }
        ];
      };
  };
}
