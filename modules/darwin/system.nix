{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    curl
  ];

  nix = {
    gc = {
      automatic = true;
      interval = { Weekday = 7; };
      options = "--delete-older-than 14d";
    };
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;
}
