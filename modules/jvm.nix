{
  homeModule =
    { pkgs, ... }:

    {
      programs.java = {
        enable = true;
        package = pkgs.zulu;
      };

      home.packages = with pkgs; [
        jdt-language-server
        kotlin
        ktlint
        visualvm
      ];
    };

  nixosModule =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        eclipse-mat
      ];
    };

  darwinModule =
    { ... }:
    {
      homebrew.casks = [
        "jdk-mission-control"
        "memoryanalyzer"
      ];
    };
}
