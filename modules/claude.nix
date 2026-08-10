{
  homeModule =
    {
      config,
      lib,
      pkgs,
      pkgs-master,
      inputs,
      ...
    }:
    {
      home.file."${config.home.homeDirectory}/.claude/plugins/known_marketplaces.json".force = true;

      programs.claude-code = {
        enable = true;
        package = pkgs-master.claude-code;
        enableMcpIntegration = true;

        marketplaces = {
          claude-plugins-official = inputs.claude-plugins-official;
        };

        settings = {
          env = { };
          enableVimMode = true;
          attribution.commit = "Assisted-by: Claude Code";
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
            command =
              let
                jq = lib.getExe pkgs.jq;
                git = lib.getExe pkgs.git;
              in
              ''
                eval "$(${jq} -r '
                  (.context_window.used_percentage // 0 | floor) as $p
                  | (($p / 10 | floor) | if . > 10 then 10 else . end) as $f
                  | @sh "MODEL=\(.model.display_name // "Claude") DIR=\(.workspace.current_dir // ".") PCT=\($p) BAR=\((("▓" * $f) // "") + (("░" * (10 - $f)) // "")) LIM=\(.rate_limits.five_hour.used_percentage // 0 | floor)"
                ')"

                cd "$DIR" 2>/dev/null || true
                BRANCH=$(${git} branch --show-current 2>/dev/null)
                DIRTY=""
                if [ -n "$BRANCH" ] && ! ${git} diff --quiet --ignore-submodules HEAD 2>/dev/null; then
                  DIRTY="*"
                fi

                # green < 50% < yellow < 80% < red
                color() {
                  if [ "$1" -ge 80 ]; then echo 31
                  elif [ "$1" -ge 50 ]; then echo 33
                  else echo 32
                  fi
                }

                printf '\033[1m%s\033[0m  \033[36m%s\033[0m' "$MODEL" "''${DIR##*/}"
                [ -n "$BRANCH" ] && printf '  \033[33m⎇ %s%s\033[0m' "$BRANCH" "$DIRTY"
                printf '  \033[%sm%s\033[0m \033[2m%s%%\033[0m' "$(color "$PCT")" "$BAR" "$PCT"
                [ "$LIM" -gt 0 ] && printf '  \033[%sm5h %s%%\033[0m' "$(color "$LIM")" "$LIM"
                echo
              '';
          };
          enabledPlugins = {
            "gopls-lsp@claude-plugins-official" = true;
            "typescript-lsp@claude-plugins-official" = true;
            "rust-analyzer-lsp@claude-plugins-official" = true;
            "pyright-lsp@claude-plugins-official" = true;
            "kotlin-lsp@claude-plugins-official" = true;
            "jdtls-lsp@claude-plugins-official" = true;
            "code-review@claude-plugins-official" = true;
            "security-guidance@claude-plugins-official" = true;
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
