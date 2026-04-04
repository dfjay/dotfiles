{
  nixosModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      cfg = config.services.sing-box-relay;

      vlessUsersWithFlow = map (u: {
        uuid = config.sops.placeholder."vless_uuid_${u}";
        flow = "xtls-rprx-vision";
      }) cfg.vpnUsers;

      realityTls = {
        enabled = true;
        server_name = cfg.realityServerName;
        reality = {
          enabled = true;
          handshake = {
            server = cfg.realityServerName;
            server_port = 443;
          };
          private_key = config.sops.placeholder.reality_private_key;
          short_id = [ cfg.realityShortId ];
        };
      };

      mkUpstreamOutbound = s: {
        type = "vless";
        tag = "${s.tag}-reality";
        server = s.edgeDomain;
        server_port = 443;
        domain_resolver = "dns-direct";
        uuid = config.sops.placeholder."vless_uuid_${cfg.relayUser}";
        flow = "xtls-rprx-vision";
        tls = {
          enabled = true;
          server_name = s.realityServerName;
          reality = {
            enabled = true;
            public_key = s.realityPublicKey;
            short_id = s.realityShortId;
          };
          utls = {
            enabled = true;
            fingerprint = "chrome";
          };
        };
      };

      upstreamSubmodule = lib.types.submodule {
        options = {
          tag = lib.mkOption { type = lib.types.str; };
          edgeDomain = lib.mkOption { type = lib.types.str; };
          realityServerName = lib.mkOption {
            type = lib.types.str;
            default = "www.samsung.com";
          };
          realityPublicKey = lib.mkOption { type = lib.types.str; };
          realityShortId = lib.mkOption { type = lib.types.str; };
        };
      };
    in
    {
      options.services.sing-box-relay = {
        enable = lib.mkEnableOption "sing-box relay server";

        realityServerName = lib.mkOption {
          type = lib.types.str;
          default = "console.cloud.yandex.ru";
          description = "TLS server name for Reality handshake (inbound)";
        };

        realityShortId = lib.mkOption {
          type = lib.types.str;
          description = "Reality short ID";
        };

        realityPublicKey = lib.mkOption {
          type = lib.types.str;
          description = "Reality public key (for client configs)";
        };

        vpnUsers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "List of VPN user names (for inbound auth)";
        };

        relayUser = lib.mkOption {
          type = lib.types.str;
          default = "dfjay";
          description = "User whose UUID is used for outbound connections to upstream servers";
        };

        upstreams = lib.mkOption {
          type = lib.types.listOf upstreamSubmodule;
          description = "Upstream VPN servers to relay traffic to";
        };

        defaultUpstream = lib.mkOption {
          type = lib.types.str;
          description = "Tag of the default upstream server (e.g. fr-reality)";
        };

        sharedSecretsFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to shared sops secrets (UUIDs)";
        };

        serverSecretsFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to server-specific sops secrets (reality private key)";
        };
      };

      config = lib.mkIf cfg.enable {
        sops = {
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

          secrets = {
            reality_private_key.sopsFile = cfg.serverSecretsFile;
          }
          // builtins.listToAttrs (
            map (u: {
              name = "vless_uuid_${u}";
              value.sopsFile = cfg.sharedSecretsFile;
            }) (lib.unique (cfg.vpnUsers ++ [ cfg.relayUser ]))
          );

          templates."sing-box-config.json" = {
            restartUnits = [ "sing-box.service" ];
            content = builtins.toJSON {
              log = {
                level = "warn";
                timestamp = true;
              };
              dns = {
                servers = [
                  {
                    tag = "dns-direct";
                    type = "udp";
                    server = "9.9.9.9";
                  }
                ];
                final = "dns-direct";
                strategy = "prefer_ipv4";
              };
              inbounds = [
                {
                  type = "vless";
                  tag = "vless-reality-in";
                  listen = "::";
                  listen_port = 443;
                  users = vlessUsersWithFlow;
                  tls = realityTls;
                }
              ];
              outbounds = (map mkUpstreamOutbound cfg.upstreams) ++ [
                {
                  type = "direct";
                  tag = "direct";
                }
              ];
              route = {
                rules = [
                  {
                    port = [
                      25
                      587
                      465
                    ];
                    action = "reject";
                  }
                ];
                final = cfg.defaultUpstream;
                default_domain_resolver = "dns-direct";
              };
            };
          };
        };

        networking.firewall = {
          enable = true;
          logRefusedConnections = true;
          allowedTCPPorts = [
            22
            443
          ];
        };

        services.sing-box = {
          enable = true;
          settings = { };
        };

        systemd.services.sing-box.serviceConfig = {
          ExecStart = lib.mkForce [
            ""
            "${pkgs.sing-box}/bin/sing-box run -c ${config.sops.templates."sing-box-config.json".path}"
          ];
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        };
      };
    };
}
