{
  description = "dfjay flake config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, stylix, disko, impermanence, hyprland, ... }:
  {
    # darwin-rebuild build --flake .#dfjay-laptop
    darwinConfigurations = {
      "dfjay-laptop" = 
        let
          username = "dfjay";  
          useremail = "mail@dfjay.com";
          specialArgs = inputs // { inherit inputs username useremail; };
        in
        nix-darwin.lib.darwinSystem {
          inherit specialArgs;
          modules = [ 
            ({ pkgs, lib, ... }: {
              # Set Git commit hash for darwin-version.
              system.configurationRevision = self.rev or self.dirtyRev or null;

              # $ darwin-rebuild changelog
              system.stateVersion = 6;
              system.primaryUser = username;

              nixpkgs.hostPlatform = "aarch64-darwin";

              users.users.dfjay = {
                name = username;
                home = "/Users/${username}";
              };
            })

            stylix.darwinModules.stylix
            ./hosts/macos
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./hosts/macos/home.nix;
            }
          ];
        };
    };

    nixosConfigurations = {
      dfjay-desktop = 
        let
          username = "dfjay";  
          useremail = "mail@dfjay.com";
          specialArgs = inputs // { inherit inputs username useremail; };
        in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";
          modules = [
            stylix.nixosModules.stylix
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
            ./hosts/desktop
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./hosts/desktop/home.nix;
            }
          ];
        };
    };
  };
}
