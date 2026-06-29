{
  homeModule =
    { pkgs, lib, ... }:

    {
      programs.go = {
        enable = true;
      };

      home.sessionPath = [
        "$HOME/go/bin"
      ];

      home.packages = with pkgs; [
        delve
        golangci-lint
        golangci-lint-langserver
        gopls
        gosec
      ];

      programs.claude-code.settings = {
        permissions.allow = [
          "Bash(go build *)"
          "Bash(go test *)"
          "Bash(go vet *)"
          "Bash(go fmt *)"
          "Bash(go list *)"
          "Bash(go env *)"
          "Bash(go mod *)"
          "Bash(golangci-lint *)"
          "Bash(gofumpt *)"
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
                  if [[ "$file" == *.go ]]; then
                    ${lib.getExe pkgs.golangci-lint} fmt --no-config -E gofumpt -E goimports "$file" 2>/dev/null
                    dir=$(dirname "$file")
                    cd "$dir" && ${lib.getExe pkgs.go} vet ./... 2>&1 | head -20
                  fi
                '';
                statusMessage = "Go: format + vet...";
              }
            ];
          }
        ];
      };
    };
}
