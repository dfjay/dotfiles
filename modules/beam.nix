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
                languages.elixir.enable = true;
                languages.gleam.enable = true;
              };
            };
          }
        )
      ];

      programs.zed-editor.extensions = [
        "elixir"
        "gleam"
      ];

      home.packages =
        (with pkgs.beam29Packages; [
          elixir
          elixir-ls
          erlang
          rebar3
        ])
        ++ (with pkgs; [ gleam ]);
    };
}
