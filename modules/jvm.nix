{
  homeModule =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      programs.java = {
        enable = true;
        package = pkgs.zulu;
      };

      programs.zed-editor.userSettings.lsp.kotlin-lsp.binary.env = {
        JAVA_HOME = config.programs.java.package.home;
        IJ_JAVA_OPTIONS = "-Dcom.jetbrains.ls.imports.gradle.java.home=${config.programs.java.package.home}";
      };

      home.packages =
        with pkgs;
        [
          async-profiler
          eclipse-mat
          jdt-language-server
          kotlin
          ktlint
        ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [
          kotlin-lsp
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
