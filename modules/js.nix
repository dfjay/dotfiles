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
        vue-language-server
      ];
    };
}
