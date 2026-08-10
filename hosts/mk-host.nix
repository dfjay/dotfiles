{
  inputs,
  lib,
  getModules,
  flakeModules,
}:
hostCfg:
let
  inherit (hostCfg)
    host
    user
    useremail
    system
    homeStateVersion
    ;
  userdesc = hostCfg.userdesc or user;
  hostModules = hostCfg.modules or [ ];
  hostConfig = hostCfg.config or null;

  isDarwin = lib.hasSuffix "-darwin" system;
  systemClass = if isDarwin then "darwin" else "nixos";

  modulesFor = class: getModules class flakeModules hostModules;

  nixpkgs = inputs.${hostCfg.nixpkgs or "nixpkgs"};
  home-manager = inputs.${hostCfg.home-manager or "home-manager"};

  pkgs-master = import inputs.nixpkgs-master {
    inherit system;
    config.allowUnfree = true;
  };

  # Identical for every class, so a module written against a NixOS host keeps
  # working when a darwin host picks it up.
  specialArgs = {
    inherit
      inputs
      user
      useremail
      userdesc
      host
      pkgs-master
      ;
    username = user;
    hostname = host;
  };

  overlays = (import ../overlays) ++ [
    inputs.firefox-addons.overlays.default
  ];

  homeDirectory = if isDarwin then "/Users/${user}" else "/home/${user}";

  homeManagerModule = {
    home-manager.backupFileExtension = "backup";
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = specialArgs;
    home-manager.users.${user} =
      { ... }:
      {
        imports = modulesFor "homeManager";
        home = {
          username = user;
          inherit homeDirectory;
          stateVersion = homeStateVersion;
        };
      };
  };

  nixosModules = [
    {
      system.stateVersion = hostCfg.nixosStateVersion;
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = overlays;

      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 14d";
        };
        settings = {
          auto-optimise-store = true;
          min-free = "1G";
          max-free = "5G";
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
    homeManagerModule
  ]
  ++ modulesFor "nixos";

  darwinModules = [
    {
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      system.stateVersion = hostCfg.darwinStateVersion;
      system.primaryUser = user;
      nixpkgs.hostPlatform = system;
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = overlays;
      users.users.${user} = {
        name = user;
        home = homeDirectory;
      };

      security.pam.services.sudo_local.touchIdAuth = true;

      nix = {
        gc = {
          automatic = true;
          interval = {
            Weekday = 7;
          };
          options = "--delete-older-than 14d";
        };
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    }
    home-manager.darwinModules.home-manager
    homeManagerModule
  ]
  ++ modulesFor "darwin";

  inert = builtins.filter (
    name:
    builtins.isString name
    && !(flakeModules.${systemClass} ? ${name})
    && !(flakeModules.homeManager ? ${name})
  ) hostModules;

  modules =
    lib.throwIf (inert != [ ])
      "host ${host}: no ${systemClass} or home-manager module in ${lib.concatStringsSep ", " inert}"
      (
        (if isDarwin then darwinModules else nixosModules) ++ lib.optional (hostConfig != null) hostConfig
      );
in
if isDarwin then
  {
    flake.darwinConfigurations.${host} = inputs.nix-darwin.lib.darwinSystem {
      inherit specialArgs modules;
    };
  }
else
  {
    flake.nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
      inherit system specialArgs modules;
    };
  }
