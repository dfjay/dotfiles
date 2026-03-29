{
  nixosModule =
    { ... }:
    {
      virtualisation.docker = {
        enable = true;
        rootless = {
          enable = false;
          setSocketVariable = false;
        };
      };
    };

  darwinModule =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        colima
        docker
        docker-credential-helpers
        dive
      ];
    };

  homeModule =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        dockerfile-language-server
        docker-compose-language-service
      ];
    };
}
