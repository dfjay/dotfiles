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
    # system
    audio
    bluetooth
    de.cosmic
    firewall
    games
    locale
    sops
    stylix

    # tools
    bat
    beam
    btop
    claude
    direnv
    docker
    eza
    fastfetch
    fd
    formats
    ghostty
    git
    go
    gpg
    helix
    js
    just
    jvm
    k8s
    lazydocker
    lazygit
    librewolf
    nix
    nix-index
    nushell
    python
    ripgrep
    rust
    skim
    ssh
    starship
    tailscale
    tealdeer
    yazi
    zed
    zoxide
    zsh
  ];

  config =
    {
      pkgs,
      lib,
      inputs,
      hostname,
      username,
      userdesc,
      ...
    }:
    {
      imports = [
        inputs.nixos-facter-modules.nixosModules.facter
        ./storage.nix
      ];

      facter.reportPath = ./facter.json;

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
        sops.gnupg.home = "/home/${username}/.gnupg";
        sops.secrets."netrc".path = "/home/${username}/.netrc";
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
        # system
        devenv
        home-manager
        nh
        pinentry-gnome3
        sbctl

        # sensors
        coolercontrol.coolercontrold
        coolercontrol.coolercontrol-ui-data
        lm_sensors

        # CLI
        colmena
        gnumake
        gopass
        gpg-tui
        k6
        postgresql
        usbutils

        # GUI
        bitwarden-desktop
        brave
        discord
        libreoffice-qt
        prismlauncher
        qbittorrent
        telegram-desktop
        tor-browser
        via
      ];

      environment.variables.EDITOR = "hx";

      programs.throne = {
        enable = true;
        tunMode.enable = true;
      };
    };
}
