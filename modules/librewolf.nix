{
  homeModule =
    { pkgs, lib, ... }:
    let
      sharedExtensions = with pkgs.firefox-addons; [
        bitwarden
        clearurls
        kagi-privacy-pass
        kagi-search
        kagi-translate
        multi-account-containers
        vimium
        wappalyzer
      ];

      sharedSettings = {
        # Read trusted root CAs from the macOS Keychain / Linux NSS store
        # instead of only Librewolf's bundled set. Needed for mkcert,
        # corporate CAs (e.g. Spectrum), and other locally-installed roots.
        "security.enterprise_roots.enabled" = true;

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

        # Vertical tabs (Firefox 138+ native implementation).
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        # Without this the sidebar collapses on launch and tabs become invisible.
        "sidebar.visibility" = "always-show";
        # Compact UI density — slimmer tabs and toolbar.
        "browser.uidensity" = 1;
      };

      sharedSearch = {
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

      # macOS: a minimal .app bundle that launches LibreWolf with the work
      # profile. Lands in ~/Applications/Home Manager Apps/ via home-manager's
      # native app-linker and is picked up by Spotlight.
      librewolfWorkAppDarwin = pkgs.runCommandLocal "librewolf-work-app" { } ''
        APP="$out/Applications/Librewolf Work.app"
        mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

        cat > "$APP/Contents/Info.plist" <<'EOF'
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleName</key><string>Librewolf Work</string>
          <key>CFBundleDisplayName</key><string>Librewolf Work</string>
          <key>CFBundleExecutable</key><string>launcher</string>
          <key>CFBundleIdentifier</key><string>io.librewolf.work</string>
          <key>CFBundlePackageType</key><string>APPL</string>
          <key>CFBundleShortVersionString</key><string>1.0</string>
          <key>CFBundleIconFile</key><string>firefox</string>
          <key>LSUIElement</key><false/>
        </dict>
        </plist>
        EOF

        cat > "$APP/Contents/MacOS/launcher" <<EOF
        #!/bin/bash
        exec "${pkgs.librewolf}/Applications/LibreWolf.app/Contents/MacOS/librewolf" -P work --no-remote "\$@"
        EOF
        chmod +x "$APP/Contents/MacOS/launcher"

        cp "${pkgs.librewolf}/Applications/LibreWolf.app/Contents/Resources/firefox.icns" \
           "$APP/Contents/Resources/firefox.icns"
      '';

      # Linux: extra .desktop entry next to the regular Librewolf one, picked
      # up by COSMIC / GNOME / KDE app launchers.
      librewolfWorkDesktopLinux = pkgs.makeDesktopItem {
        name = "librewolf-work";
        desktopName = "Librewolf Work";
        genericName = "Web Browser (Work)";
        exec = "${pkgs.librewolf}/bin/librewolf -P work --no-remote %U";
        icon = "librewolf";
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeTypes = [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
      };
    in
    {
      programs.librewolf = {
        enable = true;

        profiles = {
          # Personal — keeps the existing `default` directory so history,
          # bookmarks and logins are preserved across the rename.
          default = {
            id = 0;
            isDefault = true;
            extensions.packages =
              sharedExtensions
              ++ (with pkgs.firefox-addons; [
                metamask
              ]);
            settings = sharedSettings;
            search = sharedSearch;
          };

          work = {
            id = 1;
            extensions.packages =
              sharedExtensions
              ++ (with pkgs.firefox-addons; [
                react-devtools
              ]);
            settings = sharedSettings;
            search = sharedSearch;
          };
        };
      };

      stylix.targets.librewolf.profileNames = [
        "default"
        "work"
      ];

      home.packages =
        lib.optional pkgs.stdenv.isDarwin librewolfWorkAppDarwin
        ++ lib.optional pkgs.stdenv.isLinux librewolfWorkDesktopLinux;
    };
}
