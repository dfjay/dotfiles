{
  homeModule =
    { pkgs, ... }:

    {
      programs.rofi = {
        enable = true;
        plugins = [ pkgs.rofi-calc ];
        package = pkgs.rofi-wayland;
        terminal = "${pkgs.kitty}/bin/kitty";
        extraConfig = {
          modi = "drun";
          show-icons = true;
          drun-display-format = "{icon} {name}";
          disable-history = false;
          hide-scrollbar = true;
          display-drun = " Apps ";
          sidebar-mode = true;
        };
      };

      home.packages = (with pkgs; [ bemoji ]);
    };
}
