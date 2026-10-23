{ profiles, ... }:

{
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  userdesc = "Pavel Yozhikov";
  nixpkgs = "nixpkgs-stable";
  home-manager = "home-manager-stable";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  modules = profiles.server;

  colmena = {
    targetHost = "regru-vps";
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

      services.resolved.settings.Resolve.FallbackDNS = [
        "194.58.125.120"
        "194.67.94.40"
      ];

      imports = [
        inputs.nixos-facter-modules.nixosModules.facter
        inputs.princo.nixosModules.default
        ./storage.nix
      ];

      facter.reportPath = ./facter.json;

      # headless: the emulated QEMU vga would pull in mesa
      facter.detected.graphics.enable = false;

      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      sops.age.sshKeyPaths = [ ];

      services.princo = {
        enable = true;
        config = ../../vpn/princo.yaml;
        node = "ru";
        planPkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      };
      security.acme.acceptTerms = true;

      users = {
        defaultUserShell = pkgs.bash;
        mutableUsers = true;
        users.${username} = {
          isNormalUser = true;
          description = userdesc;
          extraGroups = [ "wheel" ];
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
