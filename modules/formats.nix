{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        bash-language-server
        marksman
        shellcheck
        taplo
        vscode-langservers-extracted
        yaml-language-server
      ];
    };
}
