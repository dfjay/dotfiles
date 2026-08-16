{
  homeModule =
    { config, pkgs, ... }:

    let
      inherit (config.lib.stylix.colors.withHashtag)
        base00
        base01
        base02
        base03
        base04
        base05
        base08
        base0A
        base0B
        base0D
        base0E
        ;
      style = s: "'${s}'";
    in
    {
      home.packages = [ pkgs.postgresql ];

      programs.pgcli = {
        enable = true;

        settings = {
          main = {
            destructive_statements_require_transaction = true;

            auto_expand = true;

            syntax_style = "monokai";

            less_chatty = true;
          };

          colors = {
            "completion-menu.completion" = style "bg:${base01} ${base05}";
            "completion-menu.completion.current" = style "bg:${base0D} ${base00}";
            "completion-menu.meta.completion" = style "bg:${base01} ${base03}";
            "completion-menu.meta.completion.current" = style "bg:${base0D} ${base00}";
            "completion-menu.multi-column-meta" = style "bg:${base02} ${base05}";
            "scrollbar" = style "bg:${base02}";
            "scrollbar.arrow" = style "bg:${base01}";
            "selected" = style "bg:${base02} ${base05}";
            "search" = style "bg:${base0A} ${base00}";
            "search.current" = style "bg:${base0B} ${base00}";
            "bottom-toolbar" = style "bg:${base01} ${base04}";
            "bottom-toolbar.off" = style "bg:${base01} ${base03}";
            "bottom-toolbar.on" = style "bg:${base01} ${base05}";
            "bottom-toolbar.transaction.valid" = style "bg:${base01} ${base0B} bold";
            "bottom-toolbar.transaction.failed" = style "bg:${base01} ${base08} bold";
            "search-toolbar" = style "noinherit bg:${base01} ${base0A} bold";
            "search-toolbar.text" = style "nobold ${base05}";
            "system-toolbar" = style "noinherit bg:${base01} ${base0E} bold";
            "arg-toolbar" = style "noinherit bg:${base01} ${base0E} bold";
            "arg-toolbar.text" = style "nobold ${base05}";
            "prompt" = style base0D;
            "continuation" = style base03;
            "output.header" = style "${base0D} bold";
            "output.null" = style base03;
          };
        };
      };
    };
}
