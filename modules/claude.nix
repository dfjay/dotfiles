{
  homeModule =
    { config, pkgs, pkgs-master, inputs, ... }:
    {
      sops.secrets.context7_api_key = { };

      sops.templates."mcp.json" = {
        path = "${config.home.homeDirectory}/.mcp.json";
        content = builtins.toJSON {
          mcpServers = {
            context7 = {
              type = "http";
              url = "https://mcp.context7.com/mcp";
              headers = {
                CONTEXT7_API_KEY = config.sops.placeholder.context7_api_key;
              };
            };
          };
        };
      };

      programs.claude-code = {
        enable = true;
        package = pkgs-master.claude-code-bin;

        marketplaces = {
          claude-plugins-official = inputs.claude-plugins-official;
          goland-claude-marketplace = inputs.go-modern-guidelines;
          superpowers-dev = inputs.claude-superpowers;
        };

        settings = {
          env = { };
          enableVimMode = true;
          includeCoAuthoredBy = true;
          permissions = {
            allow = [
              # git
              "Bash(git status *)"
              "Bash(git diff *)"
              "Bash(git log *)"
              "Bash(git show *)"
              "Bash(git blame *)"
              "Bash(git branch *)"
              "Bash(git stash *)"
              "Bash(git fetch *)"
              "Bash(git rev-parse *)"
              "Bash(git remote *)"
              "Bash(git add *)"

              # go
              "Bash(go build *)"
              "Bash(go test *)"
              "Bash(go vet *)"
              "Bash(go fmt *)"
              "Bash(go list *)"
              "Bash(go env *)"
              "Bash(go mod *)"
              "Bash(golangci-lint *)"
              "Bash(gofumpt *)"

              # kotlin/jvm
              "Bash(gradle build *)"
              "Bash(gradle test *)"
              "Bash(./gradlew build *)"
              "Bash(./gradlew test *)"

              # node
              "Bash(npm run *)"
              "Bash(npm test *)"

              # nix
              "Bash(nix build *)"
              "Bash(nix eval *)"
              "Bash(nix flake *)"
              "Bash(nixfmt *)"

              # utilities
              "Bash(jq *)"
              "Bash(which *)"
              "Bash(ls *)"
              "Bash(pwd)"
              "Bash(cat *)"
              "Bash(head *)"
              "Bash(tail *)"
              "Bash(find *)"
              "Bash(grep *)"
              "Bash(rg *)"
              "Bash(wc *)"
              "Bash(sort *)"
              "Bash(env *)"
              "Bash(mkdir *)"
              "Bash(echo *)"
            ];
            deny = [
              "Bash(rm -rf /)"
              "Bash(rm -rf /*)"
              "Bash(sudo *)"
            ];
          };
          statusLine = {
            type = "command";
            command = ''input=$(cat); MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"'); DIR=$(basename "$(echo "$input" | jq -r '.workspace.current_dir')"); BRANCH=$(cd "$(echo "$input" | jq -r '.workspace.current_dir')" 2>/dev/null && git branch --show-current 2>/dev/null); printf "\033[1m%s\033[0m in \033[36m%s\033[0m" "$MODEL" "$DIR"; [ -n "$BRANCH" ] && printf " on \033[33m⎇ %s\033[0m" "$BRANCH"; echo'';
          };
          enabledPlugins = {
            "modern-go-guidelines@goland-claude-marketplace" = true;
            "gopls-lsp@claude-plugins-official" = true;
            "typescript-lsp@claude-plugins-official" = true;
            "rust-analyzer-lsp@claude-plugins-official" = true;
            "pyright-lsp@claude-plugins-official" = true;
            "kotlin-lsp@claude-plugins-official" = true;
            "code-review@claude-plugins-official" = true;
            "security-guidance@claude-plugins-official" = true;
            "superpowers@superpowers-dev" = true;
            "frontend-design@claude-plugins-official" = true;
          };
          hooks = {
            PostToolUse = [
              {
                matcher = "Edit|Write";
                hooks = [
                  {
                    type = "command";
                    command = ''
                      input=$(cat)
                      file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
                      case "$file" in
                        *.go)
                          gofumpt -w "$file" 2>/dev/null
                          goimports -w "$file" 2>/dev/null
                          ;;
                        *.nix)
                          nixfmt "$file" 2>/dev/null
                          ;;
                        *.kt|*.kts)
                          ktlint --format "$file" 2>/dev/null
                          ;;
                      esac
                    '';
                    statusMessage = "Formatting...";
                  }
                  {
                    type = "command";
                    command = ''
                      input=$(cat)
                      file=$(echo "$input" | jq -r '.tool_input.file_path // empty')
                      if [[ "$file" == *.go ]]; then
                        dir=$(dirname "$file")
                        cd "$dir" && go vet ./... 2>&1 | head -20
                      fi
                    '';
                    statusMessage = "Running go vet...";
                  }
                ];
              }
            ];
          };

          skipDangerousModePermissionPrompt = true;
        };

        lspServers = {
          nix = {
            command = "${pkgs.nixd}/bin/nixd";
            extensionToLanguage = {
              ".nix" = "nix";
            };
          };
          zig = {
            command = "${pkgs.zls}/bin/zls";
            extensionToLanguage = {
              ".zig" = "zig";
            };
          };
          yaml = {
            command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
            args = [ "--stdio" ];
            extensionToLanguage = {
              ".yaml" = "yaml";
              ".yml" = "yaml";
            };
          };
          toml = {
            command = "${pkgs.taplo}/bin/taplo";
            args = [
              "lsp"
              "stdio"
            ];
            extensionToLanguage = {
              ".toml" = "toml";
            };
          };
        };

        mcpServers = {
          playwright = {
            command = "npx";
            args = [
              "@playwright/mcp@latest"
              "--browser"
              "chromium"
            ];
            type = "stdio";
          };
        };
      };
    };
}
