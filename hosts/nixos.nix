{ inputs, lib, ... }:
let
  self-lib = import ../lib.nix { inherit lib; };
  inherit (self-lib) modules getHomeModules getNixosModules;

  mkNixosConfiguration =
    {
      host,
      user,
      useremail ? "mail@dfjay.com",
      userdesc ? user,
      system,
      homeModules ? [ ],
      nixosModules ? [ ],
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
          (
            { ... }:
            {
              nixpkgs.overlays = [ inputs.nix-vscode-extensions.overlays.default ];
            }
          )
          inputs.stylix.nixosModules.stylix
          inputs.disko.nixosModules.disko
          inputs.preservation.nixosModules.preservation
          inputs.sops-nix.nixosModules.sops
          inputs.lanzaboote.nixosModules.lanzaboote
        ]
        ++ getNixosModules nixosModules
        ++ (if hostConfig != null then [ hostConfig ] else [ ])
        ++ [
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${user} =
              { pkgs, ... }:
              {
                imports = getHomeModules homeModules;
                home = {
                  username = user;
                  homeDirectory = "/home/${user}";
                  stateVersion = "26.05";
                  packages = with pkgs; [
                    nerd-fonts.fira-code
                    nerd-fonts.droid-sans-mono
                    nerd-fonts.noto
                    nerd-fonts.hack
                    nerd-fonts.ubuntu
                  ];
                };
                news.display = "show";
                programs.home-manager.enable = true;
              };
          }
        ];
      };
    };

  vps = import ./linode-vps { inherit modules; };
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

      linode-vps = {
        deployment = {
          targetHost = vps.colmena.targetHost;
          targetUser = vps.colmena.targetUser;
          buildOnTarget = true;
        };
        imports = conf.linode-vps._module.args.modules;
      };
    };

  imports = [
    (mkNixosConfiguration {
      host = "linode-vps";
      inherit (vps)
        system
        user
        userdesc
        homeModules
        nixosModules
        ;
      hostConfig = vps.config;
      nixpkgs = inputs.nixpkgs-stable;
      home-manager = inputs.home-manager-stable;
    })
    (mkNixosConfiguration {
      host = "dfjay-desktop";
      inherit (desktop)
        system
        user
        userdesc
        homeModules
        nixosModules
        ;
      hostConfig = desktop.config;
    })
  ];
}
