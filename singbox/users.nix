{ lib }:
let
  users = {
    dfjay = {
      servers = [
        "fr"
        "us"
      ];
    };
    chu74 = {
      servers = [
        "fr"
        "us"
      ];
    };
    chu52 = {
      servers = [
        "fr"
        "us"
      ];
    };
    vdv7 = {
      servers = [
        "fr"
        "us"
      ];
    };
    gtn5 = {
      servers = [ "us" ];
    };
  };
in
{
  inherit users;
  allUsers = lib.attrNames users;
  serverUsers = tag: lib.attrNames (lib.filterAttrs (_: u: lib.elem tag u.servers) users);
}
