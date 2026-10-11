final: _prev: {
  playwright-cli =
    let
      browsers = final.playwright-driver.browsers.override {
        withFirefox = false;
        withWebkit = false;
      };
    in
    final.runCommand "playwright-cli-${final.playwright-test.version}"
      {
        nativeBuildInputs = [ final.makeBinaryWrapper ];
        passthru.skill = "${final.playwright-test}/lib/node_modules/playwright-core/lib/tools/skills/playwright-cli";
        meta.mainProgram = "playwright-cli";
      }
      ''
        makeWrapper ${final.playwright-test}/bin/playwright $out/bin/playwright-cli \
          --add-flags cli \
          --set-default PLAYWRIGHT_BROWSERS_PATH ${browsers} \
          --set-default PLAYWRIGHT_MCP_BROWSER chromium
      '';
}
