{
  inputs,
  lib,
  config,
  self-lib,
  ...
}:
let
  inherit (self-lib) modules profiles getModules;

  mkHost = import ./mk-host.nix {
    inherit inputs lib getModules;
    flakeModules = config.flake.modules;
  };

  subdirs = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.));

  isSelfManaged = name: builtins.pathExists (./. + "/${name}/flake-module.nix");

  selfManaged = lib.filter isSelfManaged subdirs;

  hosts = lib.genAttrs (lib.filter (name: !isSelfManaged name) subdirs) (
    name: (import (./. + "/${name}") { inherit modules profiles; }) // { host = name; }
  );

  colmenaHosts = lib.filterAttrs (_: hostCfg: hostCfg ? colmena) hosts;
in
{
  imports =
    map (name: ./. + "/${name}/flake-module.nix") selfManaged ++ lib.mapAttrsToList (_: mkHost) hosts;

  flake.colmena =
    let
      conf = inputs.self.nixosConfigurations;
    in
    {
      meta = {
        nixpkgs = import inputs.nixpkgs-stable { system = "x86_64-linux"; };
        nodeNixpkgs = lib.mapAttrs (_: node: node.pkgs) conf;
        nodeSpecialArgs = lib.mapAttrs (_: node: node._module.specialArgs) conf;
      };
    }
    // lib.mapAttrs (name: hostCfg: {
      deployment = {
        buildOnTarget = true;
      }
      // hostCfg.colmena;
      imports = conf.${name}._module.args.modules;
    }) colmenaHosts;
}
