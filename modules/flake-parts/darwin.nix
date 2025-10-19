{ inputs, ... }:
{
  flake.darwinConfigurations = {
    "dfjay-laptop" =
      let
        username = "dfjay";
        useremail = "mail@dfjay.com";
        hostname = "dfjay-laptop";

        specialArgs = inputs // {
          inherit inputs username useremail;
        };
      in
      inputs.nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [
          (
            {
              pkgs,
              lib,
              ...
            }:
            {
              # Set Git commit hash for darwin-version.
              system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

              # $ darwin-rebuild changelog
              system.stateVersion = 6;
              system.primaryUser = username;

              nixpkgs.hostPlatform = "aarch64-darwin";

              nixpkgs.overlays = [ inputs.nix-vscode-extensions.overlays.default ];

              users.users.dfjay = {
                name = username;
                home = "/Users/${username}";
              };
            }
          )

          inputs.stylix.darwinModules.stylix
          inputs.sops-nix.darwinModules.sops
          ../../hosts/macos
          inputs.mac-app-util.darwinModules.default

          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.sharedModules = [
              inputs.mac-app-util.homeManagerModules.default
              inputs.nix4nvchad.homeManagerModules.default
            ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username} = import ../../hosts/macos/home.nix;
          }
        ];
      };
  };
}
