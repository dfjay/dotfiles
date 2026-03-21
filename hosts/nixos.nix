{ inputs, lib, ... }:
let
  self-lib = import ../lib.nix { inherit lib; };
  inherit (self-lib) modules getHomeModules getNixosModules;

  mkNixosConfiguration =
    {
      host,
      user,
      useremail,
      userdesc ? user,
      system,
      nixosStateVersion,
      homeStateVersion,
      hostModules ? [ ],
      hostConfig ? null,
      nixpkgs ? inputs.nixpkgs,
      home-manager ? inputs.home-manager,
    }:
    let
      specialArgs = inputs // {
        inherit
          inputs
          user
          useremail
          userdesc
          host
          ;
        username = user;
        hostname = host;
      };
    in
    {
      flake.nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          {
            system.stateVersion = nixosStateVersion;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              inputs.nix-vscode-extensions.overlays.default
            ]
            ++ (import ../overlays);

            nix = {
              gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 14d";
              };
              settings = {
                auto-optimise-store = true;
                experimental-features = [
                  "nix-command"
                  "flakes"
                ];
              };
            };
          }
          inputs.stylix.nixosModules.stylix
          inputs.disko.nixosModules.disko
          inputs.preservation.nixosModules.preservation
          inputs.sops-nix.nixosModules.sops
          inputs.lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
              inputs.nix-index-database.homeModules.nix-index
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${user} =
              { pkgs, ... }:
              {
                imports = getHomeModules hostModules;
                home = {
                  username = user;
                  homeDirectory = "/home/${user}";
                  stateVersion = homeStateVersion;
                };
              };
          }
        ]
        ++ getNixosModules hostModules
        ++ lib.optional (hostConfig != null) hostConfig;
      };
    };

  gandi-vps = import ./gandi-vps { inherit modules; };
  linode-vps = import ./linode-vps { inherit modules; };
  desktop = import ./dfjay-desktop { inherit modules; };

in
{
  flake.colmena =
    let
      conf = inputs.self.nixosConfigurations;
    in
    {
      meta = {
        nixpkgs = import inputs.nixpkgs-stable { system = "x86_64-linux"; };
        nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) conf;
        nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) conf;
      };

      gandi-vps = {
        deployment = {
          targetHost = gandi-vps.colmena.targetHost;
          targetUser = gandi-vps.colmena.targetUser;
          buildOnTarget = true;
        };
        imports = conf.gandi-vps._module.args.modules;
      };

      linode-vps = {
        deployment = {
          targetHost = linode-vps.colmena.targetHost;
          targetUser = linode-vps.colmena.targetUser;
          buildOnTarget = true;
        };
        imports = conf.linode-vps._module.args.modules;
      };
    };

  imports = [
    (mkNixosConfiguration {
      inherit (gandi-vps)
        host
        system
        user
        useremail
        userdesc
        nixosStateVersion
        homeStateVersion
        ;
      hostModules = gandi-vps.modules;
      hostConfig = gandi-vps.config;
      nixpkgs = inputs.nixpkgs-stable;
      home-manager = inputs.home-manager-stable;
    })
    (mkNixosConfiguration {
      inherit (linode-vps)
        host
        system
        user
        useremail
        userdesc
        nixosStateVersion
        homeStateVersion
        ;
      hostModules = linode-vps.modules;
      hostConfig = linode-vps.config;
      nixpkgs = inputs.nixpkgs-stable;
      home-manager = inputs.home-manager-stable;
    })
    (mkNixosConfiguration {
      inherit (desktop)
        host
        system
        user
        useremail
        userdesc
        nixosStateVersion
        homeStateVersion
        ;
      hostModules = desktop.modules;
      hostConfig = desktop.config;
    })
  ];
}
