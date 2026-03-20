{ modules }:

{
  host = "dfjay-desktop";
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
    stylix

    claude
    bat
    btop
    direnv
    docker
    eza
    fastfetch
    fd
    ghostty
    git
    gpg
    gradle
    helix
    k8s
    lazydocker
    lazygit
    librewolf
    neovim
    netrc
    nix-index
    postgresql
    ripgrep
    skim
    starship
    tealdeer
    translateshell
    vscode
    yazi
    zed
    zoxide
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
      lib,
      hostname,
      username,
      userdesc,
      ...
    }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      security.sudo.enable = false;
      security.sudo-rs = {
        enable = true;
        execWheelOnly = false;
      };

      virtualisation.podman.enable = true;

      programs.coolercontrol.enable = true;

      security = {
        polkit.enable = true;
      };

      # Suppress systemd-machine-id-commit.service since machine-id is persisted via preservation
      systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

      services.printing.enable = true;

      hardware = {
        cpu.amd.updateMicrocode = true;
        graphics = {
          enable = true;
          enable32Bit = true;
        };
      };

      networking = {
        hostName = hostname;
        networkmanager.enable = true;
        firewall.enable = false;
      };

      boot = {
        loader = {
          systemd-boot.enable = lib.mkForce false;
          efi.canTouchEfiVariables = true;
        };
        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            enable = true;
            autoReboot = true;
          };
        };
        initrd.systemd.enable = true;
        kernelPackages = pkgs.linuxPackages_zen;
      };

      home-manager.users.${username} = {
        sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
        services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
        services.gpg-agent.sshKeys = [
          "FB20142EEBEAA96FD7F688382F5E558BA4A23694" # YubiKey auth subkey
        ];
        programs.git.settings = {
          commit.gpgSign = true;
          tag.gpgSign = true;
          user.signingKey = "577260D68251AC22";
        };
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

      environment.systemPackages = with pkgs; [
        nh
        home-manager

        # sensors
        lm_sensors
        coolercontrol.coolercontrold
        coolercontrol.coolercontrol-ui-data

        pinentry-gnome3
        sbctl

        bitwarden-desktop
        brave
        discord
        element-desktop
        gnumake
        gopass
        gpg-tui
        grimblast
        jmeter
        just
        libreoffice-qt
        prismlauncher
        qbittorrent
        reaper
        spotify
        telegram-desktop
        tor-browser
        usbutils
        via
        woeusb
      ];

      programs.throne = {
        enable = true;
        tunMode.enable = true;
      };
    };
}
