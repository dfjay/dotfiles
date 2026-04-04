{ modules }:

{
  host = "yc-vps";
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

    sing-box-relay
  ];

  colmena = {
    targetHost = "edge-ru.dfjay.com";
    targetUser = "dfjay";
  };

  config =
    {
      pkgs,
      lib,
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
      ];

      services.sing-box-relay = {
        enable = true;
        realityShortId = "1a3287df";
        realityPublicKey = "654efZ1tti1w3gLBRnGOA2gUPT11tjz7zXoNm8ZuwjU";
        vpnUsers = [
          "dfjay"
          "chu74"
          "chu52"
          "gladiolus"
        ];
        sharedSecretsFile = ../../secrets/vpn-shared.yaml;
        serverSecretsFile = ../../secrets/vpn-yc.yaml;

        upstreams = [
          {
            tag = "fr";
            edgeDomain = "edge-fr.dfjay.com";
            realityPublicKey = "nK2Kjs_gPs7ktIY0MmjFYt32n1ZIUcViJI37ZW0vNlo";
            realityShortId = "1a3287df";
          }
        ];
        defaultUpstream = "fr-reality";
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
