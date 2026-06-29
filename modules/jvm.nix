{
  homeModule =
    { pkgs, lib, ... }:

    {
      programs.java = {
        enable = true;
        package = pkgs.zulu;
      };

      home.packages = with pkgs; [
        async-profiler
        jdt-language-server
        kotlin
        ktlint
      ];

      programs.claude-code.settings = {
        permissions.allow = [
          "Bash(gradle build *)"
          "Bash(gradle test *)"
          "Bash(./gradlew build *)"
          "Bash(./gradlew test *)"
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
                    *.kt | *.kts)
                      ${lib.getExe pkgs.ktlint} --format "$file" 2>/dev/null
                      ;;
                  esac
                '';
                statusMessage = "Kotlin: format...";
              }
            ];
          }
        ];
      };
    };

  nixosModule =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        eclipse-mat
      ];
    };

  darwinModule =
    { ... }:
    {
      homebrew.casks = [
        "jdk-mission-control"
        "memoryanalyzer"
      ];
    };
}
