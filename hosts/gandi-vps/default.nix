{ profiles, ... }:

{
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  userdesc = "Pavel Yozhikov";
  nixpkgs = "nixpkgs-stable";
  home-manager = "home-manager-stable";
  nixosStateVersion = "24.11";
  homeStateVersion = "25.11";

  modules = profiles.server;

  colmena = {
    targetHost = "gandi-vps";
    targetUser = "dfjay";
  };

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
      nixpkgs.overlays = [
        (_: prev: {
          inherit (inputs.nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system}) sing-box;
        })
      ];

      networking.hostName = hostname;

      imports = [
        inputs.nixos-facter-modules.nixosModules.facter
        inputs.princo.nixosModules.default
        ./storage.nix
      ];

      facter.reportPath = ./facter.json;

      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      sops.age.sshKeyPaths = [ ];

      services.princo = {
        enable = true;
        config = ../../vpn/princo.yaml;
        node = "fr";
        planPkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      };
      security.acme.acceptTerms = true;

      services.nginx.virtualHosts."dfjay.com" = {
        forceSSL = true;
        enableACME = true;
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
          {
            addr = "[::]";
            port = 80;
          }
          {
            addr = "127.0.0.1";
            port = 8443;
            ssl = true;
          }
          {
            addr = "[::1]";
            port = 8443;
            ssl = true;
          }
        ];
        root = "${inputs.portfolio}";
        locations."/".tryFiles = "$uri $uri/ /index.html";
      };

      users = {
        defaultUserShell = pkgs.bash;
        mutableUsers = true;
        users.${username} = {
          isNormalUser = true;
          description = userdesc;
          extraGroups = [ "wheel" ];
          openssh.authorizedKeys.keys = [
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
