{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    hyprland.url = "github:hyprwm/Hyprland";

    mac-app-util.url = "github:hraban/mac-app-util";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-vscode-extensions, stylix, disko, impermanence, hyprland, mac-app-util, nix-flatpak, sops-nix, ... }:
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

              nixpkgs.overlays = [ inputs.nix-vscode-extensions.overlays.default ];

              users.users.dfjay = {
                name = username;
                home = "/Users/${username}";
              };
            })

            stylix.darwinModules.stylix
            sops-nix.darwinModules.sops
            ./hosts/macos
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];

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
          hostname = "dfjay-desktop";
          userdesc = "Pavel Yozhikov";
          specialArgs = inputs // { inherit inputs username useremail hostname userdesc; };        
        in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";
          modules = [
            ({ pkgs, lib, ... }: {
              nixpkgs.overlays = [ inputs.nix-vscode-extensions.overlays.default ];
            })
            nix-flatpak.nixosModules.nix-flatpak
            stylix.nixosModules.stylix
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
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

      dfjay-vps = 
        let
          username = "dfjay";  
          useremail = "mail@dfjay.com";
          hostname = "dfjay-vps";
          specialArgs = inputs // { inherit inputs username useremail hostname; };
        in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";
          modules = [
            ./hosts/vps
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./hosts/vps/home.nix;
            }
          ];
        };
    };
  };
}
