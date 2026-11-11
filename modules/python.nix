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
                languages.python = {
                  enable = true;
                  lsp.servers = [
                    "basedpyright"
                    "ruff"
                  ];
                  format.type = [ "ruff" ];
                  extraDiagnostics.enable = false;
                };
              };
            };
          }
        )
      ];

      home.packages = with pkgs; [
        python315
        ruff
      ];

      programs.uv.enable = true;

      programs.claude-code.lspServers.python = {
        command = lib.getExe' pkgs.basedpyright "basedpyright-langserver";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".py" = "python";
          ".pyi" = "python";
        };
      };
    };
}
