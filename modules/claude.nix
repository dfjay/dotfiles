{
  homeModule =
    {
      config,
      pkgs,
      pkgs-master,
      inputs,
      ...
    }:
    {
      home.file."${config.home.homeDirectory}/.claude/plugins/known_marketplaces.json".force = true;

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
        package = pkgs-master.claude-code;
        enableMcpIntegration = true;

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

      };
    };
}
