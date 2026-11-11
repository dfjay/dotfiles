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
      imports = [
        (
          { options, ... }:
          {
            config = lib.optionalAttrs (options.programs ? nvf) {
              programs.nvf.settings.vim = {
                lsp.enable = true;

                languages.java = {
                  enable = true;
                  # astyle would reformat whole files on save
                  format.enable = false;
                };

                # nvf only ships the deprecated fwcd server; JetBrains kotlin-lsp is below
                languages.kotlin = {
                  enable = true;
                  lsp.enable = false;
                };

                lsp.servers.kotlin-lsp = {
                  cmd = [
                    (lib.getExe pkgs.kotlin-lsp-proxy)
                    (lib.getExe pkgs.kotlin-lsp)
                    "--stdio"
                  ];
                  cmd_env = kotlinLspEnv;
                  filetypes = [ "kotlin" ];
                  # nvf types root_markers as a flat list, where the nearest build.gradle
                  # of a submodule would win over the project's settings.gradle
                  root_dir = lib.generators.mkLuaInline ''
                    function(bufnr, on_dir)
                      on_dir(vim.fs.root(bufnr, {
                        { "settings.gradle.kts", "settings.gradle", "workspace.json" },
                        { "build.gradle.kts", "build.gradle", "pom.xml" },
                        ".git",
                      }))
                    end
                  '';
                };
              };
            };
          }
        )
      ];

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
