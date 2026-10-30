{
  homeModule =
    {
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      pocock = "${inputs.mattpocock-skills}/skills";

      trailofbitsSkills = lib.genAttrs [
        "modern-python"
        "property-based-testing"
        "second-opinion"
      ] (name: "${inputs.trailofbits-skills}/plugins/${name}/skills/${name}");

      gcxSkills = lib.genAttrs [
        "gcx"
        "debug-with-grafana"
        "investigate-alert"
        "manage-dashboards"
        "create-dashboard"
      ] (name: "${pkgs.gcx.src}/claude-plugin/skills/${name}");

      skills = {
        playwright-cli = pkgs.playwright-cli.skill;
        use-modern-go = "${inputs.go-modern-guidelines}/plugin/skills/use-modern-go";
        grilling = "${pocock}/productivity/grilling";
        tdd = "${pocock}/engineering/tdd";
        diagnosing-bugs = "${pocock}/engineering/diagnosing-bugs";
      }
      // trailofbitsSkills
      // gcxSkills;

      mkSkillFiles =
        prefix:
        lib.mapAttrs' (name: source: lib.nameValuePair "${prefix}/${name}" { inherit source; }) skills;
    in
    {
      programs.opencode.skills = skills;
      programs.claude-code.skills = skills;

      home.file = mkSkillFiles ".agents/skills";

      home.packages = [ pkgs.playwright-cli ];
    };
}
