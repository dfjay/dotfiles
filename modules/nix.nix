{
  darwinModule =
    { pkgs, ... }:
    {
      nix.linux-builder = {
        enable = true;
        package = pkgs.darwin.linux-builder-vz;
        systems = [
          "aarch64-linux"
          "x86_64-linux"
        ];
        maxJobs = 4;

        config.virtualisation = {
          cores = 4;
          darwin-builder.memorySize = 6 * 1024;
        };
      };

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
        nixos-anywhere
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
