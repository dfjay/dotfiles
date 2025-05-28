{ ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
      };
    };
  };
}
