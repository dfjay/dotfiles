{ ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [ "./wals/anime1.jpg" ];

      wallpaper = [
        "DP-1,./wals/anime1.jpg"
      ];
    };
  };
}
