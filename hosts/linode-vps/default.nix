{ modules }:

{
  system = "x86_64-linux";
  user = "dfjay";
  userdesc = "Pavel Yozhikov";
  useStable = true;

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
    targetHost = "ssh.dfjay.com";
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
        defaultSopsFile = ../../secrets/linode-vps.yaml;
        age.keyFile = "/var/lib/sops-nix/key.txt";
        secrets = {
          vless_uuid_dfjay = { };
          hysteria2_password = { };
        };
        templates = {
          "sing-box-config.json" = {
            content = builtins.toJSON {
              log = {
                level = "debug";
                timestamp = true;
              };
              dns = {
                servers = [
                  {
                    tag = "google";
                    address = "8.8.8.8";
                    detour = "direct";
                  }
                ];
                strategy = "ipv4_only";
              };
              inbounds = [
                {
                  type = "vless";
                  tag = "vless-ws-in";
                  listen = "127.0.0.1";
                  listen_port = 10446;
                  users = [
                    {
                      uuid = config.sops.placeholder.vless_uuid_dfjay;
                    }
                  ];
                  transport = {
                    type = "ws";
                    path = "/ws";
                  };
                }
                {
                  type = "hysteria2";
                  tag = "hysteria2-in";
                  listen = "::";
                  listen_port = 8443;
                  users = [
                    {
                      password = config.sops.placeholder.hysteria2_password;
                    }
                  ];
                  tls = {
                    enabled = true;
                    acme = {
                      domain = [ "hy2.dfjay.com" ];
                      email = "mail@dfjay.com";
                      data_directory = "/var/lib/sing-box/acme";
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
          "vless-ws-subscription" = {
            content = "vless://${config.sops.placeholder.vless_uuid_dfjay}@subs.dfjay.com:443?encryption=none&security=tls&sni=subs.dfjay.com&type=ws&path=%2Fws#dfjay-ws";
          };
          "hysteria2-subscription" = {
            content = "hysteria2://${config.sops.placeholder.hysteria2_password}@hy2.dfjay.com:8443?sni=hy2.dfjay.com#dfjay-hy2";
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
          initialPassword = "changeme"; # for LISH console only, change after first login
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
        };
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          22 # SSH
          80 # HTTP / Caddy
          443 # HTTPS / Caddy
        ];
        allowedUDPPorts = [
          8443 # Hysteria2
        ];
      };

      services.caddy = {
        enable = true;
        email = "mail@dfjay.com"; # for Let's Encrypt notifications

        virtualHosts."dfjay.com".extraConfig = ''
          respond "Welcome" 200
        '';

        virtualHosts."subs.dfjay.com".extraConfig = ''
          handle /ws {
            reverse_proxy 127.0.0.1:10446
          }

          handle {
            root * /var/lib/caddy/subscription
            file_server
          }
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
        description = "Generate VLESS subscription file";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          mkdir -p /var/lib/caddy/subscription
          mkdir -p /var/lib/sing-box/acme

          # Create combined subscription (VLESS-WS + Hysteria2)
          cat ${config.sops.templates."vless-ws-subscription".path} > /tmp/sub-combined
          echo "" >> /tmp/sub-combined
          cat ${config.sops.templates."hysteria2-subscription".path} >> /tmp/sub-combined
          ${pkgs.coreutils}/bin/base64 -w 0 /tmp/sub-combined > /var/lib/caddy/subscription/dfjay
          rm /tmp/sub-combined

          # Set proper permissions
          chown -R caddy:caddy /var/lib/caddy/subscription
          chmod 644 /var/lib/caddy/subscription/*
          chown -R sing-box:sing-box /var/lib/sing-box
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

      system.stateVersion = "25.05";
    };
}
