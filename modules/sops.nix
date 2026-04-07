let
  defaultSopsConfig = {
    defaultSopsFile = ../secrets/secret.yaml;
    defaultSopsFormat = "yaml";
  };
in
{
  nixosModule =
    { inputs, pkgs, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = defaultSopsConfig;
      environment.systemPackages = [ pkgs.sops ];
    };

  darwinModule =
    { inputs, pkgs, ... }:
    {
      imports = [ inputs.sops-nix.darwinModules.sops ];
      environment.systemPackages = [ pkgs.sops ];
    };

  homeModule =
    { inputs, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      sops = defaultSopsConfig;
    };
}
