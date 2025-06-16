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

          svelte.svelte-vscode
          vue.volar
        ];

        userSettings = {
          "files.autoSave" = "afterDelay";
          "python.analysis.typeCheckingMode" = "standard";
        };
      };
    };
  };
}
