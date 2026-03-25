{ modules }:

{
  host = "gandi-vps";
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  userdesc = "Pavel Yozhikov";
  nixpkgs = "nixpkgs-stable";
  home-manager = "home-manager-stable";
  nixosStateVersion = "24.11";
  homeStateVersion = "25.11";

  modules = with modules; [
    locale
    sops

    bat
    btop
    eza
    git
    helix
    ripgrep
    starship
    yazi
    zoxide
  ];

  colmena = {
    targetHost = "edge-fr.dfjay.com";
    targetUser = "dfjay";
  };

  config =
    {
      pkgs,
      lib,
      config,
      inputs,
      username,
      userdesc,
      ...
    }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          sing-box = inputs.nixpkgs.legacyPackages.${prev.system}.sing-box;
        })
      ];

      imports = [
        ./hardware-configuration.nix
        ../../modules/sing-box-server.nix
      ];

      services.sing-box-vpn = {
        enable = true;
        edgeDomain = "edge-fr.dfjay.com";
        naiveDomain = "naive-fr.dfjay.com";
        realityShortId = "1a3287df";
        vpnUsers = [
          "dfjay"
          "chu74"
          "chu52"
          "gladiolus"
        ];
        sharedSecretsFile = ../../secrets/vpn-shared.yaml;
        serverSecretsFile = ../../secrets/vpn-gandi.yaml;

        subscription = {
          enable = true;
          domain = "subs.dfjay.com";
          servers = [
            {
              tag = "fr";
              edgeDomain = "edge-fr.dfjay.com";
              naiveDomain = "naive-fr.dfjay.com";
              realityShortId = "1a3287df";
              realityPublicKey = "nK2Kjs_gPs7ktIY0MmjFYt32n1ZIUcViJI37ZW0vNlo";
            }
            {
              tag = "us";
              edgeDomain = "edge-us.dfjay.com";
              naiveDomain = "naive-us.dfjay.com";
              realityShortId = "1a3287df";
              realityPublicKey = "WauUnrXr3NyKrgExAXEeJ6TVqn3Sqc8xFoEU7Pt1VXs";
            }
          ];
        };

        portfolio = {
          enable = true;
          domain = "dfjay.com";
          root = inputs.portfolio;
        };
      };

      security.sudo.wheelNeedsPassword = false;

      users = {
        defaultUserShell = pkgs.bash;
        mutableUsers = true;
        users.${username} = {
          isNormalUser = true;
          description = userdesc;
          extraGroups = [ "wheel" ];
          initialPassword = "changeme";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9W6B9WBu7PbMJWdKGFzBLMR1y2IK+kFuSsIWh2fwqg dfjay@dfjay-laptop.local"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFmvdG0pEwUZcsrElS/5B+jR9PYfEECrtgy8VLs5pwR cardno:20_488_896"
          ];
        };
      };

      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = lib.mkForce "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          MaxAuthTries = 3;
          X11Forwarding = false;
          AllowAgentForwarding = false;
        };
      };

      services.fail2ban = {
        enable = true;
        maxretry = 3;
        bantime = "1h";
      };

      environment.systemPackages = with pkgs; [
        curl
        wget
        vim
        htop
        git
        mtr
        inetutils
        sysstat
        tcpdump
        jq
        dig
        wireguard-tools
        iperf3
        nmap
      ];

      security.sudo.enable = true;
    };
}
