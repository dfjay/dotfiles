{ inputs, lib, ... }:
let
  self-lib = import ../lib.nix { inherit lib; };
  inherit (self-lib) modules getHomeModules getDarwinModules;

  mkDarwinConfiguration =
    {
      host,
      user,
      useremail ? "mail@dfjay.com",
      system,
      homeModules ? [ ],
      darwinModules ? [ ],
      hostConfig ? null,
    }:
    let
      pkgs-master = import inputs.nixpkgs-master {
        inherit system;
        config.allowUnfree = true;
      };

      specialArgs = inputs // {
        inherit inputs;
        username = user;
        inherit useremail pkgs-master;
      };
    in
    {
      flake.darwinConfigurations.${host} = inputs.nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [
          (
            { ... }:
            {
              system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
              system.stateVersion = 6;
              system.primaryUser = user;
              nixpkgs.hostPlatform = system;
              nixpkgs.overlays = [
                inputs.nix-vscode-extensions.overlays.default
                (final: prev: {
                  openfortivpn = prev.openfortivpn.overrideAttrs (old: rec {
                    version = "1.24.1";
                    src = final.fetchFromGitHub {
                      owner = "adrienverge";
                      repo = "openfortivpn";
                      rev = "v${version}";
                      hash = "sha256-zJSEBfhb2dFEOW/sJyB7xFLGGUQLjkz20V80L0ew7J8=";
                    };
                  });
                })
              ];
              users.users.${user} = {
                name = user;
                home = "/Users/${user}";
              };
            }
          )
          inputs.stylix.darwinModules.stylix
          inputs.sops-nix.darwinModules.sops
        ]
        ++ getDarwinModules darwinModules
        ++ (if hostConfig != null then [ hostConfig ] else [ ])
        ++ [
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.sharedModules = [
              inputs.nix4nvchad.homeManagerModules.default
              inputs.sops-nix.homeManagerModules.sops
            ];
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${user} =
              { ... }:
              {
                imports = getHomeModules homeModules;
                home = {
                  username = user;
                  homeDirectory = "/Users/${user}";
                  stateVersion = "25.11";
                };
                programs.home-manager.enable = true;
              };
          }
        ];
      };
    };

  laptop = import ./dfjay-laptop { inherit modules; };

in
{
  imports = [
    (mkDarwinConfiguration {
      host = "dfjay-laptop";
      inherit (laptop)
        system
        user
        homeModules
        darwinModules
        ;
      hostConfig = laptop.config;
    })
  ];
}
