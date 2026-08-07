{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        actionlint
        bash-language-server
        bats
        marksman
        shellcheck
        taplo
        vscode-langservers-extracted
        yaml-language-server
      ];
    };
}
