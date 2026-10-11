{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        moonlight-qt
        prismlauncher
      ];
    };

  nixosModule =
    { ... }:

    {
      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };
      programs.gamemode.enable = true;

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession.enable = true;
      };

      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = false;
      };
    };

  darwinModule =
    { ... }:

    {
      homebrew.casks = [ "steam" ];
    };
}
