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
              '':sh if [ -n "$ZELLIJ" ]; then zellij run -c -f -x 10%% -y 10%% --width 80%% --height 80%% -- bash $HOME/.config/helix/yazi-picker.sh open %{buffer_name}; fi''
              '':insert-output if [ -z "$ZELLIJ" ]; then yazi %{buffer_name} --chooser-file=/tmp/hx-yazi-chooser; fi''
              '':sh printf '\x1b[?1049h\x1b[?2004h' > /dev/tty''
              ":open %sh{cat /tmp/hx-yazi-chooser 2>/dev/null}"
              ":redraw"
            ];

            # Lazygit
            "C-g" = [
              ":write-all"
              '':sh if [ -n "$ZELLIJ" ]; then zellij run -c -f -x 2%% -y 2%% --width 95%% --height 95%% -- lazygit; fi''
              ":new"
              '':insert-output if [ -z "$ZELLIJ" ]; then lazygit; fi''
              ":buffer-close!"
              ":redraw"
              ":reload-all"
            ];
          };
        };
      };

      xdg.configFile."helix/yazi-picker.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          paths=$(yazi "$2" --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)
          if [[ -n "$paths" ]]; then
              zellij action toggle-floating-panes
              zellij action write 27
              zellij action write-chars ":$1 $paths"
              zellij action write 13
          else
              zellij action toggle-floating-panes
          fi
        '';
      };
    };
}
