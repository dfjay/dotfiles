{
  nixosModule =
    { config, ... }:
    {
      sops = {
        defaultSopsFile = ../secrets/secret.yaml;
        defaultSopsFormat = "yaml";
      };
    };
}
