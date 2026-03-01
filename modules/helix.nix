{
  homeModule =
    { ... }:

    {
      programs.helix = {
        enable = true;
        settings = {
          editor = {
            line-number = "relative";
            lsp.display-messages = true;
          };

          keys.normal = {
            # Yazi
            "C-e" = [
              ":sh rm -f /tmp/hx-yazi-chooser"
              ":insert-output yazi %{buffer_name} --chooser-file=/tmp/hx-yazi-chooser"
              '':sh printf '\x1b[?1049h\x1b[?2004h' > /dev/tty''
              ":open %sh{cat /tmp/hx-yazi-chooser 2>/dev/null}"
              ":redraw"
            ];

            # Lazygit
            "C-g" = [
              ":write-all"
              ":new"
              ":insert-output lazygit"
              ":buffer-close!"
              ":redraw"
              ":reload-all"
            ];
          };
        };
      };

    };
}
