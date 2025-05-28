{ ... }:

{
  programs.vscode {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    userSettings = {
      "files.autoSave": "afterDelay",
      "workbench.colorTheme": "GitHub Dark Default",
      "editor.fontSize" = 14;

      "python.analysis.typeCheckingMode": "standard",
     # "python.envFile": "${workspaceFolder}/.env",
    };®
    keybindings = {

    };
  };
}
