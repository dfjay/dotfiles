{
  homeModule =
    { pkgs, ... }:

    {
      programs.lutris = {
        enable = true;
        steamPackage = pkgs.steam;
        winePackages = with pkgs; [
          wineWow64Packages.stable
        ];
        protonPackages = with pkgs; [
          proton-ge-bin
        ];
        extraPackages = with pkgs; [
          winetricks
        ];
      };
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
    };
}
