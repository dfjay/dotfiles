{
  nixosModule =
    { pkgs, ... }:

    {
      time.timeZone = "Asia/Yekaterinburg";

      i18n.defaultLocale = "en_US.UTF-8";
      i18n.supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "ru_RU.UTF-8/UTF-8"
      ];
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "ru_RU.UTF-8";
        LC_IDENTIFICATION = "ru_RU.UTF-8";
        LC_MEASUREMENT = "ru_RU.UTF-8";
        LC_MONETARY = "ru_RU.UTF-8";
        LC_NAME = "ru_RU.UTF-8";
        LC_NUMERIC = "ru_RU.UTF-8";
        LC_PAPER = "ru_RU.UTF-8";
        LC_TELEPHONE = "ru_RU.UTF-8";
        LC_TIME = "ru_RU.UTF-8";
      };

      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      environment.systemPackages = with pkgs; [
        # spell checker
        hunspell
        hunspellDicts.ru_RU
        hunspellDicts.en_US
      ];
    };
}
