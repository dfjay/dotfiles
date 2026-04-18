{
  homeModule =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        just
        just-lsp
      ];
    };
}
