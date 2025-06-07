{ ... }:

{
  services.mako = {
    enable = true;

    settings = {
      max-history = 100;
      max-visible = 5;

      border-radius = 10;
      border-size = 2;
      default-timeout = 5000;

      margin = "10";
      padding = "15";
      width = 300;
      height = 100;
    };


    #extraConfig = ''
    #  [urgency=low]
    #  border-color=#313244
    #  default-timeout=2000
#
    #  [urgency=normal]
    #  border-color=#cba6f7
    #  default-timeout=5000
#
    #  [urgency=high]
    #  border-color=#f38ba8
    #  text-color=#f38ba8
    #  default-timeout=0
##
    #  [category=mpd]
    #  border-color=#f9e2af
    #  default-timeout=2000
    #  group-by=category
    #'';
  };
}
