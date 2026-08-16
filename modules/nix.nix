{
  darwinModule = _: {
    nix.linux-builder = {
      enable = true;
      maxJobs = 4;

      config.virtualisation.cores = 4;
    };

    sops.secrets.nix_builder_key = {
      sopsFile = ../secrets/secret.yaml;
      path = "/etc/nix/id_builder";
      mode = "0600";
      owner = "root";
    };

    nix.buildMachines = [
      {
        hostName = "dfjay-desktop";
        systems = [ "x86_64-linux" ];
        sshUser = "nixremote";
        sshKey = "/etc/nix/id_builder";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1JYnk5R2FFTktYV0VocTZ6bnA0VWM1akFLc1h0cTRZWUpFTjVZSS9NZXYK";
        maxJobs = 8;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
    ];

    nix.settings.trusted-users = [ "@admin" ];
  };

  homeModule =
    { pkgs, lib, ... }:

    {
      home.packages = with pkgs; [
        colmena
        devenv
        nixd
        nixfmt
      ];

      programs.claude-code.settings = {
        permissions.allow = [
          "Bash(nix build *)"
          "Bash(nix eval *)"
          "Bash(nix flake *)"
          "Bash(nixfmt *)"
        ];
        hooks.PostToolUse = [
          {
            matcher = "Edit|Write";
            hooks = [
              {
                type = "command";
                command = ''
                  input=$(cat)
                  file=$(echo "$input" | ${lib.getExe pkgs.jq} -r '.tool_input.file_path // empty')
                  case "$file" in
                    *.nix)
                      ${lib.getExe pkgs.nixfmt} "$file" 2>/dev/null
                      ;;
                  esac
                '';
                statusMessage = "Nix: format...";
              }
            ];
          }
        ];
      };
    };
}
