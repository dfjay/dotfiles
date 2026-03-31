{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        biome
        bun
        nodejs_24
        npm-check-updates
        tsx
        typescript-language-server
      ];
    };
}
