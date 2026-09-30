{ modules, profiles, ... }:

{
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  userdesc = "Pavel Yozhikov";
  nixpkgs = "nixpkgs-stable";
  home-manager = "home-manager-stable";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  modules = profiles.server ++ [
    (import ../../singbox/server.nix)
  ];

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
    let
      vpn = import ../../singbox/users.nix { inherit lib; };
    in
    {
      nixpkgs.overlays = [
        (_: prev: {
          inherit (inputs.nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system}) sing-box;
        })
      ];

      networking.hostName = hostname;

      imports = [
        inputs.nixos-facter-modules.nixosModules.facter
        ./storage.nix
      ];

      facter.reportPath = ./facter.json;

      # headless: the emulated QEMU vga would pull in mesa
      facter.detected.graphics.enable = false;

      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      sops.age.sshKeyPaths = [ ];

      services.sing-box-vpn = {
        enable = true;
        tag = "ru";
        edgeDomain = "edge-ru.dfjay.com";
        naiveDomain = "naive-ru.dfjay.com";
        realityShortId = "f0447be7";
        realityServerName = "www.ozon.ru";
        realityPublicKey = "OaF4Ru6_I-f7fGXQoRqDgxWYyNC3LGp7qcdPLpkhMDg";
        domestic = true;
        vpnUsers = vpn.serverUsers "ru";
        sharedSecretsFile = ../../secrets/shared.yaml;
        serverSecretsFile = ../../secrets/regru-vps.yaml;
      };

      security.sudo.wheelNeedsPassword = false;

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
