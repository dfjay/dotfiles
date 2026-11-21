{
  darwinModule = {
    homebrew.brews = [ "ollama" ];
  };

  homeModule =
    { pkgs, lib, ... }:
    {
      services.ollama = {
        enable = true;
        package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
          pkgs.writeShellScriptBin "ollama" ''
            exec /opt/homebrew/bin/ollama "$@"
          ''
        );
      };

      programs.zed-editor.userSettings.edit_predictions = {
        provider = "ollama";
        ollama = {
          api_url = "http://localhost:11434";
          model = "zeta2.1";
          prompt_format = "infer";
          max_output_tokens = 512;
        };
      };
    };
}
