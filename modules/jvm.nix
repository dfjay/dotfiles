{
  homeModule =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    let
      javaHome = config.programs.java.package.home;

      kotlinLspEnv = {
        JAVA_HOME = javaHome;
        IJ_JAVA_OPTIONS = "-Dcom.jetbrains.ls.imports.gradle.java.home=${javaHome}";
      };
    in
    {
      programs.java = {
        enable = true;
        package = pkgs.zulu;
      };

      programs.zed-editor.userSettings.lsp.kotlin-lsp.binary.env = kotlinLspEnv;

      home.packages = with pkgs; [
        async-profiler
        eclipse-mat
        jdt-language-server
        kotlin
        kotlin-lsp
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

  darwinModule =
    { ... }:
    {
      homebrew.casks = [
        "jdk-mission-control"
      ];
    };
}
