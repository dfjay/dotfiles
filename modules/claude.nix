{
  homeModule =
    {
      config,
      pkgs,
      inputs,
      ...
    }:
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

        marketplaces = {
          claude-plugins-official = inputs.claude-plugins-official;
          goland-claude-marketplace = inputs.go-modern-guidelines;
        };

        settings = {
          env = { };
          enableVimMode = true;
          includeCoAuthoredBy = true;
          permissions = {
            allow = [
              "Bash(npm run lint)"
              "Bash(npm run test:*)"
              "Bash(npm test:*)"
              "Bash(git status)"
              "Bash(git diff:*)"
              "Bash(git log:*)"
              "Bash(git add:*)"
              "Bash(git commit:*)"
              "Bash(git push)"
              "Bash(git config:*)"
              "Bash(git tag:*)"
              "Bash(git branch:*)"
              "Bash(git checkout:*)"
              "Bash(git stash:*)"
              "Bash(jq:*)"
              "Bash(node:*)"
              "Bash(which:*)"
              "Bash(pwd)"
              "Bash(ls:*)"
            ];
            deny = [
              "Bash(rm -rf /)"
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
            "elixir-ls-lsp@claude-plugins-official" = true;
            "kotlin-lsp@claude-plugins-official" = true;
            "code-review@claude-plugins-official" = true;
            "security-guidance@claude-plugins-official" = true;
            "superpowers@claude-plugins-official" = true;
            "frontend-design@claude-plugins-official" = true;
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
