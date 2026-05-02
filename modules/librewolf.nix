{
  homeModule =
    { pkgs, ... }:

    {
      programs.librewolf = {
        enable = true;

        profiles = {
          default = {
            extensions.packages = with pkgs.firefox-addons; [
              bitwarden
              clearurls
              kagi-privacy-pass
              kagi-search
              kagi-translate
              metamask
              multi-account-containers
              react-devtools
              vimium
              wappalyzer
            ];

            settings = {
              # Don't wipe cookies/history/tabs on browser close (Librewolf's
              # default). Keeps logins and session.
              "privacy.sanitize.sanitizeOnShutdown" = false;
              "privacy.clearOnShutdown.cookies" = false;
              "privacy.clearOnShutdown.history" = false;
              "privacy.clearOnShutdown.sessions" = false;
              "privacy.clearOnShutdown.offlineApps" = false;
              "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
              "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;

              # Restore previous session on launch.
              "browser.startup.page" = 3;
            };

            search = {
              force = true;
              default = "kagi";
              privateDefault = "kagi";
              order = [
                "kagi"
                "ddg"
              ];
              engines.kagi = {
                name = "Kagi";
                urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
                icon = "https://kagi.com/favicon.ico";
                definedAliases = [ "@k" ];
              };
            };
          };
        };
      };

      stylix.targets.librewolf.profileNames = [ "default" ];
    };
}
