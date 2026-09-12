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
          claude-plugins-nix = inputs.claude-plugins-official;
        };

        settings = {
          env = { };
          enableVimMode = true;
          attribution.commit = "Assisted-by: Claude Code";
          # Keeps the claude.ai session link out of commit messages; this repo
          # is public, so the session id would be published with it.
          attribution.sessionUrl = false;
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
                  def left:
                    (. - now | floor) as $s
                    | if $s <= 0 then ""
                      elif $s >= 86400 then "\($s / 86400 | floor)d\($s % 86400 / 3600 | floor)h"
                      elif $s >= 3600 then "\($s / 3600 | floor)h\($s % 3600 / 60 | floor)m"
                      else "\($s / 60 | floor)m"
                      end;
                  def pct: .used_percentage // 0 | floor;
                  (.rate_limits.five_hour // {}) as $h
                  | @sh "MODEL=\(.model.display_name // "Claude") DIR=\(.workspace.current_dir // ".") PCT=\(.context_window | pct) H5=\($h | pct) H5R=\($h.resets_at // 0 | left) D7=\(.rate_limits.seven_day // {} | pct)"
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
                printf '  \033[2m%s%%\033[0m' "$PCT"

                SEP="  \033[2m│\033[0m"
                limit() {
                  [ "$2" -gt 0 ] || return 0
                  printf "$SEP"
                  SEP=""
                  printf '  \033[%sm%s %s%%\033[0m' "$(color "$2")" "$1" "$2"
                  [ -n "$3" ] && printf ' \033[2m↻%s\033[0m' "$3"
                  return 0
                }
                limit 5h "$H5" "$H5R"
                limit 7d "$D7" ""
                echo
              '';
          };
          enabledPlugins = {
            "gopls-lsp@claude-plugins-nix" = true;
            "typescript-lsp@claude-plugins-nix" = true;
            "rust-analyzer-lsp@claude-plugins-nix" = true;
            "pyright-lsp@claude-plugins-nix" = true;
            "kotlin-lsp@claude-plugins-nix" = true;
            "jdtls-lsp@claude-plugins-nix" = true;
            "code-review@claude-plugins-nix" = true;
            "security-guidance@claude-plugins-nix" = true;
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
