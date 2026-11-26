{
  nixosModule =
    { config, lib, ... }:

    {
      preservation.preserveAt."/persist".directories = lib.mkIf config.preservation.enable [
        "/var/lib/bluetooth"
      ];

      hardware.bluetooth = {
        enable = true;
        settings.General.Experimental = true; # bluetooth percentage
      };
    };
}
