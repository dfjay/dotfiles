{ modules }:

{
  system = "x86_64-linux";
  user = "dfjay";
  useremail = "mail@dfjay.com";
  userdesc = "Pavel Yozhikov";
  useStable = true;

  nixosStateVersion = "24.11";
  homeStateVersion = "25.11";

  modules = with modules; [
    locale

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

  # Colmena deployment settings
  colmena = {
    targetHost = "46.226.105.135"; # update to dfjay.com once DNS is pointed
    targetUser = "dfjay";
  };

  config =
    {
      pkgs,
      lib,
      config,
      username,
      userdesc,
      ...
    }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      sops = {
        defaultSopsFile = ../../secrets/vps.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        secrets = {
          vless_uuid_dfjay = { };
          reality_private_key = { };
          reality_public_key = { };
        };
        templates = {
          "sing-box-config.json" = {
            content = builtins.toJSON {
              log = {
                level = "info";
                timestamp = true;
              };
              inbounds = [
                {
                  type = "vless";
                  tag = "vless-reality-in";
                  listen = "::";
                  listen_port = 443;
                  users = [
                    {
                      uuid = config.sops.placeholder.vless_uuid_dfjay;
                      flow = "xtls-rprx-vision";
                    }
                  ];
                  tls = {
                    enabled = true;
                    server_name = "www.microsoft.com";
                    reality = {
                      enabled = true;
                      handshake = {
                        server = "www.microsoft.com";
                        server_port = 443;
                      };
                      private_key = config.sops.placeholder.reality_private_key;
                      short_id = [ "abcdef12" ];
                    };
                  };
                }
              ];
              outbounds = [
                {
                  type = "direct";
                  tag = "direct";
                }
              ];
              route = {
                final = "direct";
              };
            };
          };
          "vless-reality-subscription" = {
            content = "vless://${config.sops.placeholder.vless_uuid_dfjay}@dfjay.com:443?security=reality&sni=www.microsoft.com&fp=chrome&pbk=${config.sops.placeholder.reality_public_key}&sid=abcdef12&flow=xtls-rprx-vision#dfjay-reality";
          };
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
          initialPassword = "changeme"; # for console only, change after first login
          openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE9M/4cz4CbBLjyZlTDaS+MXK5X4wx+Jbap3TN1dRyO9NbXhIkaxNf/FRjKWkuluOeX59m5MsUHccG5D5L5QCUxZigl5oHmWk4Gwc+WNx5R9rSwxiI6fhzWUzyduyKnHlz/UMTmGyvG0Xc/FGMS9TKNaz6lXSyRZtCWaDhsR12URJ7MxkYuU483UT/TS6jcO6k0w+WTCXbdBz4XsK7bKFMbh1Ed36VM4Y/UxCYP4W2VHrLd4+BvqX760bIab0PH5FWHl9Kzg0ff/7Q97atUeMd5r0GfZfS5+SEDORW07rjdeRailE0aq3xDwvugx27BcqCWbIDibSwPjrpZsG1oEfGZ41P+IxEYIIN5YCM4c8MT7hUZ9/ramhIK93pVl5tnlXHloi9VmYiXneGply43DyNw6aGtGquV6AxM7Lz/YtYxr9gK5rFO/L8ZaBmorDSKgROY9GxC7varnZxLb+t6zlSDCz035eH1/8bd0ak7p1TVZnPgx285DzuAcCTaPddLAc= dfjay@Pavels-MacBook-Pro.local"
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

      networking.firewall = {
        enable = true;
        logRefusedConnections = true;
        allowedTCPPorts = [
          22 # SSH
          80 # HTTP / Caddy (subscription + placeholder site)
          443 # VLESS + Reality (sing-box)
        ];
      };

      # Caddy serves HTTP only — port 443 is taken by sing-box Reality
      services.caddy = {
        enable = true;

        virtualHosts."http://dfjay.com".extraConfig = ''
          respond "Welcome" 200
        '';

        virtualHosts."http://subs.dfjay.com".extraConfig = ''
          root * /var/lib/caddy/subscription
          file_server
        '';
      };

      services.sing-box = {
        enable = true;
        settings = { }; # Configuration loaded from sops template
      };

      # Override sing-box to use sops-generated config
      systemd.services.sing-box = {
        serviceConfig = {
          ExecStart = lib.mkForce [
            "" # Clear the original ExecStart (required by systemd)
            "${pkgs.sing-box}/bin/sing-box run -c ${config.sops.templates."sing-box-config.json".path}"
          ];
        };
      };

      # Subscription file generator (using sops template)
      systemd.services.subscription-generator = {
        description = "Generate VLESS Reality subscription file";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          mkdir -p /var/lib/caddy/subscription
          ${pkgs.coreutils}/bin/base64 -w 0 ${config.sops.templates."vless-reality-subscription".path} > /var/lib/caddy/subscription/dfjay
          chown -R caddy:caddy /var/lib/caddy/subscription
          chmod 644 /var/lib/caddy/subscription/*
        '';
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
      ];

      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 14d";
        };
        settings = {
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
      };

      nixpkgs.config.allowUnfree = true;

      security.sudo.enable = true;
    };
}
