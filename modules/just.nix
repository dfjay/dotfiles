{
  homeModule =
    { pkgs, lib, ... }:
    {
      imports = [
        (
          { options, ... }:
          {
            config = lib.optionalAttrs (options.programs ? nvf) {
              programs.nvf.settings.vim = {
                lsp.enable = true;
                languages.just.enable = true;
              };
            };
          }
        )
      ];

      programs.zed-editor.extensions = [ "justfile" ];

      home.packages = with pkgs; [
        just
        just-lsp
      ];
    };
}
