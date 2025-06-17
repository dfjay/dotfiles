{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        extensions = with pkgs.nix-vscode-extensions.vscode-marketplace; [
          ms-vscode-remote.remote-containers
          ms-azuretools.vscode-containers
          eamodio.gitlens
          vscodevim.vim
          ms-kubernetes-tools.vscode-kubernetes-tools

          sonarsource.sonarlint-vscode
          streetsidesoftware.code-spell-checker
          streetsidesoftware.code-spell-checker-russian

          chrmarti.regex

          redhat.vscode-yaml
          redhat.vscode-xml
          mechatroner.rainbow-csv
          janisdd.vscode-edit-csv

          ms-python.python
          ms-python.debugpy
          ms-python.pylint
          ms-python.vscode-pylance
          ms-toolsai.jupyter

          oracle.oracle-java
          vscjava.vscode-java-debug
          vscjava.vscode-gradle
          vscjava.vscode-maven
          vscjava.vscode-java-test
          vscjava.vscode-java-dependency
          redhat.java

          fwcd.kotlin # todo: replace to official kotlin lsp

          golang.go

          dbaeumer.vscode-eslint
          esbenp.prettier-vscode
          formulahendry.auto-close-tag
          pranaygp.vscode-css-peek
          vitest.explorer
          svelte.svelte-vscode
          vue.volar
        ];

        userSettings = {
          "files.autoSave" = "afterDelay";
          "python.analysis.typeCheckingMode" = "standard";

          "cSpell.language" = "en,ru";
        };
      };
    };
  };
}
