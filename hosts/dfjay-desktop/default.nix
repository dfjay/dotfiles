{ modules }:

{
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  userdesc = "Pavel Yozhikov";

  nixosStateVersion = "25.11";
  homeStateVersion = "26.05";

  modules = with modules; [
    audio
    bluetooth
    de.cosmic
    games
    locale
    shell.zsh
    sops
    system
    stylix

    bat
    btop
    direnv
    eza
    fastfetch
    ghostty
    git
    gpg
    gradle
    helix
    k8s
    kitty
    lazydocker
    lazygit
    librewolf
    neovim
    postgresql
    ripgrep
    skim
    starship
    translateshell
    vscode
    yazi
    zed
    zoxide
    netrc
    zsh

    languages.go
    languages.jdk
    languages.js
    languages.kotlin
    languages.python
    languages.rust
  ];

  config =
    {
      pkgs,
      username,
      userdesc,
      ...
    }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      sops.gnupg.home = "/home/${username}/.gnupg";

      home-manager.users.${username} = {
        sops.gnupg.home = "/home/${username}/.gnupg";
        programs.git.includes = [
          {
            path = "~/spectrum/.gitconfig";
            condition = "gitdir:~/spectrum/";
          }
        ];
      };

      users = {
        defaultUserShell = pkgs.zsh;
        mutableUsers = false;
        users.${username} = {
          isNormalUser = true;
          description = userdesc;
          extraGroups = [
            "networkmanager"
            "wheel"
            "docker"
          ];
          hashedPassword = "$6$J91OG.NW1Dz35n2S$L8pwihewop1tEe.x6YbjYIHRgyyax9E.q.mu/HL49xZkJEVD8DzKn.9s2rWJLWrJuL1WdpJ9NzymWQvJMBro8.";
        };
      };

      services.v2raya.enable = true;

      environment.systemPackages = with pkgs; [
        android-studio
        bitwarden-desktop
        brave
        claude-code
        discord
        element-desktop
        gnumake
        gopass
        gpg-tui
        grimblast
        jetbrains.idea
        jmeter
        just
        libreoffice-qt
        lunarvim
        prismlauncher
        qbittorrent
        reaper
        spotify
        telegram-desktop
        tor-browser
        tuifimanager
        usbutils
        via
        v2rayn
        winetricks
        wineWow64Packages.stable
        woeusb
      ];

      programs.throne = {
        enable = true;
        tunMode.enable = true;
      };
    };
}
