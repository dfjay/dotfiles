{ lib }:
let
  inherit (builtins) readDir;
  inherit (lib)
    any
    attrValues
    concatMapAttrs
    filterAttrs
    hasSuffix
    mapAttrs
    mapAttrs'
    nameValuePair
    removeSuffix
    ;

  classes = {
    nixos = "nixosModule";
    darwin = "darwinModule";
    homeManager = "homeModule";
  };

  isBundle = value: any (attr: value ? ${attr}) (attrValues classes);

  collectFiles =
    path:
    let
      contents = readDir path;

      nixFiles = filterAttrs (
        name: type: type == "regular" && hasSuffix ".nix" name && name != "default.nix"
      ) contents;

      subDirs = filterAttrs (_: type: type == "directory") contents;
    in
    mapAttrs' (
      filename: _: nameValuePair (removeSuffix ".nix" filename) (import (path + "/${filename}"))
    ) nixFiles
    // mapAttrs (dirname: _: collectFiles (path + "/${dirname}")) subDirs;

  tree = collectFiles ./modules;

  flatName = prefix: name: if prefix == "" then name else "${prefix}-${name}";

  flatten =
    prefix: node:
    concatMapAttrs (
      name: value:
      let
        n = flatName prefix name;
      in
      if isBundle value then { ${n} = value; } else flatten n value
    ) node;

  flat = flatten "" tree;

  # Leaves are the published names, not the modules, so a typo in a host list
  # surfaces as an undefined variable where it was written.
  names =
    prefix: node:
    mapAttrs (
      name: value:
      let
        n = flatName prefix name;
      in
      if isBundle value then n else names n value
    ) node;

  modules = names "" tree;

in
{
  inherit modules;

  profiles = lib.fix (
    self:
    mapAttrs (
      _: profile:
      profile {
        inherit modules;
        profiles = self;
      }
    ) (collectFiles ./profiles)
  );

  # Published as flake.modules.<class>.<name> so that any other file can extend
  # a module by defining into the same name.
  flakeModules = mapAttrs (
    _: attr: mapAttrs (_: bundle: bundle.${attr}) (filterAttrs (_: bundle: bundle ? ${attr}) flat)
  ) classes;

  # An entry naming no class at all is rejected by mk-host.nix, not here.
  getModules =
    class: flakeModules: entries:
    let
      attr = classes.${class};
      available = flakeModules.${class} or { };
      resolve =
        entry:
        if builtins.isString entry then
          lib.optional (available ? ${entry}) available.${entry}
        else
          lib.optional (entry ? ${attr}) entry.${attr};
    in
    lib.concatMap resolve entries;
}
