{
  homeModule =
    { ... }:

    {
      programs.tmux = {
        enable = true;

        keyMode = "vi";
        mouse = true;
        baseIndex = 1;
        historyLimit = 50000;
        terminal = "tmux-256color";
        aggressiveResize = true;

        extraConfig = ''
          set -ga terminal-features ",*:RGB"
          set -g renumber-windows on

          set -g set-clipboard on

          set -g detach-on-destroy off

          bind -T copy-mode-vi v send -X begin-selection
          bind -T copy-mode-vi y send -X copy-selection-and-cancel
          bind -T copy-mode-vi x send -X select-line
          bind -T copy-mode-vi g send -X history-top
          bind -T copy-mode-vi G send -X history-bottom
        '';
      };

      home.shellAliases = {
        t = "tmux new -A -s main";
      };
    };
}
