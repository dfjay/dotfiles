{ pkgs, ... }:

{
  imports = [ 
    ../../modules/darwin/system.nix
  ];

  environment.systemPackages = with pkgs; [
    aria2
    docker
    docker-credential-helpers
    just
    lunarvim
  ];
  environment.variables.EDITOR = "nvim";

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    masApps = {
      #"Xcode" = 497799835;
    };

    taps = [
    ];

    brews = [
      "gnupg"
      "pinentry-mac"
      "ykman"
    ];

    casks = [
      "figma"
      "gpg-suite"
      "iina"
      "linearmouse"
      "maccy"
      "orbstack"
      #"microsoft-excel"
      #"microsoft-powerpoint"
      #"microsoft-word"
      "telegram-desktop"
      "visual-studio-code"
      #"whatsapp"
    ];
  };
}
