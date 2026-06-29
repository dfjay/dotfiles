{
  homeModule =
    { pkgs, lib, ... }:

    {
      home.packages = with pkgs; [
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
