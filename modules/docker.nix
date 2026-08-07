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
    { pkgs, username, ... }:
    {
      environment.systemPackages = with pkgs; [
        docker
        docker-credential-helpers
        dive
      ];

      # /var/run is wiped on boot; clients resolve the daemon through this path rather than DOCKER_HOST
      launchd.daemons.colima-docker-socket = {
        script = "ln -sfn /Users/${username}/.colima/default/docker.sock /var/run/docker.sock";
        serviceConfig.RunAtLoad = true;
      };
    };

  homeModule =
    { pkgs, lib, ... }:
    {
      home.packages = with pkgs; [
        dockerfile-language-server
        docker-compose-language-service
      ];

      services.colima = lib.mkIf pkgs.stdenv.isDarwin {
        enable = true;
        profiles.default = {
          isActive = true;
          isService = true;
          settings = {
            cpu = 6;
            memory = 8;
            disk = 100;
            arch = "aarch64";
            runtime = "docker";
            vmType = "vz";
            mountType = "virtiofs";
            mountInotify = true;
            mounts = [
              {
                location = "~";
                writable = true;
              }
            ];
            rosetta = false;
            binfmt = true;
            network.address = true;
          };
        };
      };
    };
}
