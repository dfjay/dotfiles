{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        biome
        bun
        nodejs_24
        npm-check-updates
        svelte-language-server
        tsx
        typescript-language-server
      ];

      programs.claude-code.settings.permissions.allow = [
        "Bash(npm run *)"
        "Bash(npm test *)"
      ];
    };
}
