{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        bash-language-server
        marksman
        taplo
        vscode-langservers-extracted
        yaml-language-server
      ];
    };
}
