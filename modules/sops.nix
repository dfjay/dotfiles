let
  defaultSopsConfig = {
    defaultSopsFile = ../secrets/secret.yaml;
    defaultSopsFormat = "yaml";
  };
in
{
  nixosModule =
    { inputs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = defaultSopsConfig;
    };

  darwinModule =
    { inputs, ... }:
    {
      imports = [ inputs.sops-nix.darwinModules.sops ];
    };

  homeModule =
    { inputs, pkgs, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      sops = defaultSopsConfig;
      home.packages = [ pkgs.sops ];
    };
}
