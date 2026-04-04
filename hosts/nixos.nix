{ inputs, lib, ... }:
let
  self-lib = import ../lib.nix { inherit lib; };
  inherit (self-lib) modules getHomeModules getNixosModules;

  mkNixosConfiguration =
    hostCfg:
    let
      nixpkgs = inputs.${hostCfg.nixpkgs or "nixpkgs"};
      home-manager = inputs.${hostCfg.home-manager or "home-manager"};

      inherit (hostCfg)
        host
        user
        useremail
        system
        nixosStateVersion
        homeStateVersion
        ;
      userdesc = hostCfg.userdesc or user;
      hostModules = hostCfg.modules or [ ];
      hostConfig = hostCfg.config or null;

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
            nixpkgs.overlays = (import ../overlays);

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
          inputs.disko.nixosModules.disko
          inputs.preservation.nixosModules.preservation
          inputs.lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${user} =
              { ... }:
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
  yc-vps = import ./yc-vps { inherit modules; };
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

      yc-vps = {
        deployment = {
          targetHost = yc-vps.colmena.targetHost;
          targetUser = yc-vps.colmena.targetUser;
          buildOnTarget = true;
        };
        imports = conf.yc-vps._module.args.modules;
      };
    };

  imports = [
    (mkNixosConfiguration gandi-vps)
    (mkNixosConfiguration linode-vps)
    (mkNixosConfiguration yc-vps)
    (mkNixosConfiguration desktop)
  ];
}
