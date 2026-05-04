{ lib }:
let
  users = {
    dfjay = {
      servers = [
        "fr"
        "us"
      ];
      relays = [ "ru-fr" ];
    };
    chu74 = {
      servers = [
        "fr"
        "us"
      ];
      relays = [ "ru-fr" ];
    };
    chu52 = {
      servers = [
        "fr"
        "us"
      ];
      relays = [ "ru-fr" ];
    };
    vdv7 = {
      servers = [
        "fr"
        "us"
      ];
      relays = [ "ru-fr" ];
    };
    gtn5 = {
      servers = [ "us" ];
      relays = [ ];
    };
  };
in
{
  inherit users;
  allUsers = lib.attrNames users;
  serverUsers = tag: lib.attrNames (lib.filterAttrs (_: u: lib.elem tag u.servers) users);
  relayUsers = tag: lib.attrNames (lib.filterAttrs (_: u: lib.elem tag u.relays) users);
}
