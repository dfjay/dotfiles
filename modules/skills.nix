{
  homeModule =
    { lib, inputs, ... }:
    let
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
    };
}
