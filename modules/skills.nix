{
  homeModule =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      homeDir = lib.escapeShellArg config.home.homeDirectory;

      superpowers = "${inputs.claude-superpowers}/skills";

      superpowersSkills = lib.genAttrs (lib.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir superpowers)
      )) (name: "${superpowers}/${name}");

      skills = {
        use-modern-go = "${inputs.go-modern-guidelines}/skills/use-modern-go";
        frontend-design = "${inputs.claude-plugins-official}/plugins/frontend-design/skills/frontend-design";
      }
      // superpowersSkills;
    in
    {
      programs.opencode.skills = skills;

      home.file = lib.mapAttrs' (
        name: source: lib.nameValuePair ".agents/skills/${name}" { inherit source; }
      ) skills;

      home.activation.jetbrainsBundledSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        jar=$(
          for base in ${homeDir}"/Library/Application Support/JetBrains" \
                      ${homeDir}"/.local/share/JetBrains"; do
            ${pkgs.coreutils}/bin/ls -1d \
              "$base"/IntelliJIdea*/plugins/ml-llm/lib/modules/intellij.ml.llm.agents.contrib.ide.idea.jar \
              2>/dev/null || true
          done | ${pkgs.coreutils}/bin/sort -V | ${pkgs.coreutils}/bin/tail -1
        )

        if [ -n "$jar" ]; then
          for skill in ij-debugger search-tools-instructions; do
            staged=$(${pkgs.coreutils}/bin/mktemp)
            if ${pkgs.unzip}/bin/unzip -p "$jar" "bundledSkills/$skill/SKILL.md" \
                 > "$staged" 2>/dev/null && [ -s "$staged" ]; then
              target=${homeDir}/.agents/skills/$skill/SKILL.md
              ${pkgs.diffutils}/bin/cmp -s "$staged" "$target" \
                || run ${pkgs.coreutils}/bin/install -Dm644 "$staged" "$target"

              run ${pkgs.coreutils}/bin/mkdir -p ${homeDir}/.claude/skills
              run ${pkgs.coreutils}/bin/ln -sfn ${homeDir}/.agents/skills/$skill \
                ${homeDir}/.claude/skills/$skill
            fi
            ${pkgs.coreutils}/bin/rm -f "$staged"
          done
        fi
      '';
    };
}
