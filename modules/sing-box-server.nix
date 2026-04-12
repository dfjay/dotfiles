{
  nixosModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      cfg = config.services.sing-box-vpn;
      sub = cfg.subscription;
      serverSubmodule = lib.types.submodule {
        options = {
          tag = lib.mkOption { type = lib.types.str; };
          edgeDomain = lib.mkOption { type = lib.types.str; };
          naiveDomain = lib.mkOption { type = lib.types.str; };
          realityServerName = lib.mkOption {
            type = lib.types.str;
            default = "www.samsung.com";
          };
          realityShortId = lib.mkOption { type = lib.types.str; };
          realityPublicKey = lib.mkOption { type = lib.types.str; };
          h2Port = lib.mkOption {
            type = lib.types.int;
            default = 2443;
          };
        };
      };

      relaySubmodule = lib.types.submodule {
        options = {
          tag = lib.mkOption { type = lib.types.str; };
          server = lib.mkOption { type = lib.types.str; };
          realityServerName = lib.mkOption {
            type = lib.types.str;
            default = "console.cloud.yandex.ru";
          };
          realityShortId = lib.mkOption { type = lib.types.str; };
          realityPublicKey = lib.mkOption { type = lib.types.str; };
        };
      };

      # ── Shared helpers ──────────────────────────────────────────────────

      vlessUsers = map (u: {
        uuid = config.sops.placeholder."vless_uuid_${u}";
      }) cfg.vpnUsers;

      vlessUsersWithFlow = map (u: u // { flow = "xtls-rprx-vision"; }) vlessUsers;

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

      httpOnlyListen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
        {
          addr = "[::]";
          port = 80;
        }
      ];

      httpsListen = httpOnlyListen ++ [
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

      selfServer = {
        inherit (cfg)
          tag
          edgeDomain
          naiveDomain
          realityServerName
          realityShortId
          realityPublicKey
          h2Port
          ;
      };

      allServers = [ selfServer ] ++ sub.servers;
    in
    {
      options.services.sing-box-vpn = {
        enable = lib.mkEnableOption "sing-box VPN server";

        tag = lib.mkOption {
          type = lib.types.str;
          description = "Short tag for this server (e.g. fr, us)";
        };

        edgeDomain = lib.mkOption {
          type = lib.types.str;
          description = "Domain for VLESS Reality and Hysteria2";
        };

        naiveDomain = lib.mkOption {
          type = lib.types.str;
          description = "Domain for Naive proxy";
        };

        realityServerName = lib.mkOption {
          type = lib.types.str;
          default = "www.samsung.com";
          description = "TLS server name for Reality handshake";
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
          description = "List of VPN user names";
        };

        sharedSecretsFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to shared sops secrets (UUIDs, hy2 password)";
        };

        serverSecretsFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to server-specific sops secrets (reality, warp keys)";
        };

        h2Port = lib.mkOption {
          type = lib.types.int;
          default = 2443;
          description = "Public port for VLESS H2 Reality";
        };

        subscription = {
          enable = lib.mkEnableOption "subscription generator";

          domain = lib.mkOption {
            type = lib.types.str;
            default = "subs.dfjay.com";
            description = "Domain for subscription site";
          };

          servers = lib.mkOption {
            type = lib.types.listOf serverSubmodule;
            default = [ ];
            description = "Additional remote VPN servers (this server is included automatically)";
          };

          relays = lib.mkOption {
            type = lib.types.listOf relaySubmodule;
            default = [ ];
            description = "Relay servers (VLESS Reality only, for 2-hop chains)";
          };
        };

        extraStreamHosts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Additional SNI hostnames to route to nginx HTTPS (8443)";
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          # ── Core VPN server ──────────────────────────────────────────────
          {
            sops = {
              secrets = {
                reality_private_key.sopsFile = cfg.serverSecretsFile;
                warp_private_key.sopsFile = cfg.serverSecretsFile;
                warp_ipv4.sopsFile = cfg.serverSecretsFile;
                warp_ipv6.sopsFile = cfg.serverSecretsFile;
                hy2_obfs_password.sopsFile = cfg.sharedSecretsFile;
              }
              // builtins.listToAttrs (
                map (u: {
                  name = "vless_uuid_${u}";
                  value.sopsFile = cfg.sharedSecretsFile;
                }) cfg.vpnUsers
              );

              templates."sing-box-config.json" = {
                restartUnits = [ "sing-box.service" ];
                content = builtins.toJSON {
                  experimental = {
                    cache_file = {
                      enabled = true;
                    };
                  };
                  log = {
                    level = "warn";
                    timestamp = true;
                  };
                  dns = {
                    servers = [
                      {
                        tag = "quad9";
                        type = "https";
                        server = "dns.quad9.net";
                        domain_resolver = "bootstrap";
                      }
                      {
                        tag = "bootstrap";
                        type = "udp";
                        server = "9.9.9.9";
                      }
                    ];
                    final = "quad9";
                    strategy = "prefer_ipv4";
                  };
                  inbounds = [
                    {
                      type = "vless";
                      tag = "vless-reality-in";
                      listen = "127.0.0.1";
                      listen_port = 8444;
                      users = vlessUsersWithFlow;
                      tls = realityTls;
                    }
                    {
                      type = "hysteria2";
                      tag = "hy2-in";
                      listen = "::";
                      listen_port = 443;
                      obfs = {
                        type = "salamander";
                        password = config.sops.placeholder.hy2_obfs_password;
                      };
                      users = map (u: {
                        name = u;
                        password = config.sops.placeholder."vless_uuid_${u}";
                      }) cfg.vpnUsers;
                      tls = {
                        enabled = true;
                        server_name = cfg.edgeDomain;
                        certificate_path = "/var/lib/acme/${cfg.edgeDomain}/fullchain.pem";
                        key_path = "/var/lib/acme/${cfg.edgeDomain}/key.pem";
                      };
                    }
                    {
                      type = "naive";
                      tag = "naive-in";
                      listen = "127.0.0.1";
                      listen_port = 8445;
                      users = map (u: {
                        username = u;
                        password = config.sops.placeholder."vless_uuid_${u}";
                      }) cfg.vpnUsers;
                      tls = {
                        enabled = true;
                        server_name = cfg.naiveDomain;
                        certificate_path = "/var/lib/acme/${cfg.naiveDomain}/fullchain.pem";
                        key_path = "/var/lib/acme/${cfg.naiveDomain}/key.pem";
                      };
                    }
                    {
                      type = "vless";
                      tag = "vless-h2-reality-in";
                      listen = "::";
                      listen_port = cfg.h2Port;
                      users = vlessUsers;
                      multiplex.enabled = true;
                      transport = {
                        type = "http";
                      };
                      tls = realityTls;
                    }
                  ];
                  endpoints = [
                    {
                      type = "wireguard";
                      tag = "warp";
                      mtu = 1280;
                      address = [
                        config.sops.placeholder.warp_ipv4
                        config.sops.placeholder.warp_ipv6
                      ];
                      private_key = config.sops.placeholder.warp_private_key;
                      peers = [
                        {
                          address = "engage.cloudflareclient.com";
                          port = 2408;
                          public_key = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
                          allowed_ips = [
                            "0.0.0.0/0"
                            "::/0"
                          ];
                        }
                      ];
                    }
                  ];
                  outbounds = [
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
                      {
                        domain_suffix = [
                          "claude.ai"
                          "anthropic.com"
                        ];
                        action = "route";
                        outbound = "direct";
                      }
                      {
                        rule_set = [ "geosite-category-ru" ];
                        action = "reject";
                      }
                      {
                        rule_set = [ "geoip-ru" ];
                        action = "reject";
                      }
                    ];
                    rule_set = [
                      {
                        tag = "geosite-category-ru";
                        type = "remote";
                        format = "binary";
                        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ru.srs";
                        download_detour = "direct";
                      }
                      {
                        tag = "geoip-ru";
                        type = "remote";
                        format = "binary";
                        url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-ru.srs";
                        download_detour = "direct";
                      }
                    ];
                    final = "warp";
                    default_domain_resolver = "bootstrap";
                  };
                };
              };
            };

            networking.firewall = {
              enable = true;
              logRefusedConnections = true;
              allowedTCPPorts = [
                22
                80
                443
                cfg.h2Port
              ];
              allowedUDPPorts = [ 443 ];
            };

            security.acme = {
              acceptTerms = true;
              defaults.email = lib.mkDefault "mail@dfjay.com";
              certs."${cfg.edgeDomain}".reloadServices = [ "sing-box" ];
              certs."${cfg.naiveDomain}".reloadServices = [ "sing-box" ];
            };

            services.nginx = {
              enable = true;

              streamConfig =
                let
                  entries =
                    map (h: "${h} 127.0.0.1:8443;") cfg.extraStreamHosts
                    ++ lib.optional sub.enable "${sub.domain} 127.0.0.1:8443;"
                    ++ [
                      "${cfg.naiveDomain} 127.0.0.1:8445;"
                      "default 127.0.0.1:8444;"
                    ];
                in
                ''
                  map $ssl_preread_server_name $backend {
                    ${lib.concatStringsSep "\n    " entries}
                  }
                  server {
                    listen 443;
                    listen [::]:443;
                    ssl_preread on;
                    proxy_pass $backend;
                  }
                '';

              virtualHosts."${cfg.edgeDomain}" = {
                enableACME = true;
                listen = httpOnlyListen;
                locations."/".return = "404";
              };

              virtualHosts."${cfg.naiveDomain}" = {
                enableACME = true;
                listen = httpOnlyListen;
                locations."/".return = "404";
              };
            };

            services.sing-box = {
              enable = true;
              settings = { };
            };

            systemd.services.sing-box = {
              after = [
                "acme-${cfg.edgeDomain}.service"
                "acme-${cfg.naiveDomain}.service"
              ];
              serviceConfig = {
                ExecStart = lib.mkForce [
                  ""
                  "${pkgs.sing-box}/bin/sing-box run -c ${config.sops.templates."sing-box-config.json".path}"
                ];
                AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
                CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
                SupplementaryGroups = [ "acme" ];
              };
            };
          }

          # ── Subscription generator ───────────────────────────────────────
          (lib.mkIf sub.enable {
            sops.templates =
              builtins.listToAttrs (
                map (u: {
                  name = "subscription-${u}";
                  value = {
                    restartUnits = [ "subscription-generator.service" ];
                    content = builtins.concatStringsSep "\n" (
                      lib.concatMap (s: [
                        "vless://${
                          config.sops.placeholder."vless_uuid_${u}"
                        }@${s.edgeDomain}:443?encryption=none&flow=xtls-rprx-vision&type=tcp&security=reality&sni=${s.realityServerName}&fp=chrome&pbk=${s.realityPublicKey}&sid=${s.realityShortId}#${u}-${s.tag}-reality"
                        "vless://${
                          config.sops.placeholder."vless_uuid_${u}"
                        }@${s.edgeDomain}:${toString s.h2Port}?encryption=none&type=http&security=reality&sni=${s.realityServerName}&fp=chrome&pbk=${s.realityPublicKey}&sid=${s.realityShortId}#${u}-${s.tag}-h2"
                        "hysteria2://${
                          config.sops.placeholder."vless_uuid_${u}"
                        }@${s.edgeDomain}:443?sni=${s.edgeDomain}&obfs=salamander&obfs-password=${config.sops.placeholder.hy2_obfs_password}#${u}-${s.tag}-hy2"
                        "naive+https://${u}:${
                          config.sops.placeholder."vless_uuid_${u}"
                        }@${s.naiveDomain}:443#${u}-${s.tag}-naive"
                      ]) allServers
                      ++ map (
                        r:
                        "vless://${
                          config.sops.placeholder."vless_uuid_${u}"
                        }@${r.server}:443?encryption=none&flow=xtls-rprx-vision&type=tcp&security=reality&sni=${r.realityServerName}&fp=chrome&pbk=${r.realityPublicKey}&sid=${r.realityShortId}#${u}-${r.tag}-reality"
                      ) sub.relays
                    );
                  };
                }) cfg.vpnUsers
              )
              // builtins.listToAttrs (
                map (u: {
                  name = "sing-box-client-${u}.json";
                  value = {
                    restartUnits = [ "subscription-generator.service" ];
                    content = builtins.toJSON {
                      log = {
                        level = "info";
                        timestamp = true;
                      };
                      dns = {
                        servers = [
                          {
                            tag = "proxy-dns";
                            type = "https";
                            server = "dns.quad9.net";
                            detour = "select";
                            domain_resolver = "bootstrap-dns";
                          }
                          {
                            tag = "direct-dns";
                            type = "udp";
                            server = "77.88.8.8";
                          }
                          {
                            tag = "bootstrap-dns";
                            type = "udp";
                            server = "77.88.8.8";
                          }
                        ];
                        rules = [
                          {
                            rule_set = [ "geosite-category-ru" ];
                            action = "route";
                            server = "direct-dns";
                          }
                          {
                            domain_suffix = [ "3gppnetwork.org" ];
                            action = "route";
                            server = "direct-dns";
                          }
                        ];
                        final = "proxy-dns";
                        strategy = "prefer_ipv4";
                      };
                      inbounds = [
                        {
                          type = "tun";
                          tag = "tun-in";
                          address = [
                            "172.19.0.1/30"
                            "fdfe:dcba:9876::1/126"
                          ];
                          auto_route = true;
                          strict_route = true;
                          route_exclude_address_set = [ "geoip-ru" ];
                        }
                      ];
                      outbounds = [
                        {
                          type = "selector";
                          tag = "select";
                          outbounds =
                            lib.concatMap (s: [
                              "${s.tag}-reality"
                              "${s.tag}-h2"
                              "${s.tag}-hy2"
                              "${s.tag}-naive"
                            ]) allServers
                            ++ map (r: "${r.tag}-reality") sub.relays;
                          default = "${(builtins.head allServers).tag}-reality";
                        }
                      ]
                      ++ lib.concatMap (s: [
                        {
                          type = "vless";
                          tag = "${s.tag}-reality";
                          server = s.edgeDomain;
                          server_port = 443;
                          uuid = config.sops.placeholder."vless_uuid_${u}";
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
                        }
                        {
                          type = "hysteria2";
                          tag = "${s.tag}-hy2";
                          server = s.edgeDomain;
                          server_port = 443;
                          password = config.sops.placeholder."vless_uuid_${u}";
                          obfs = {
                            type = "salamander";
                            password = config.sops.placeholder.hy2_obfs_password;
                          };
                          tls = {
                            enabled = true;
                            server_name = s.edgeDomain;
                          };
                        }
                        {
                          type = "naive";
                          tag = "${s.tag}-naive";
                          server = s.naiveDomain;
                          server_port = 443;
                          username = u;
                          password = config.sops.placeholder."vless_uuid_${u}";
                          tls = {
                            enabled = true;
                            server_name = s.naiveDomain;
                          };
                        }
                        {
                          type = "vless";
                          tag = "${s.tag}-h2";
                          server = s.edgeDomain;
                          server_port = s.h2Port;
                          uuid = config.sops.placeholder."vless_uuid_${u}";
                          transport = {
                            type = "http";
                          };
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
                        }
                      ]) allServers
                      ++ map (r: {
                        type = "vless";
                        tag = "${r.tag}-reality";
                        server = r.server;
                        server_port = 443;
                        uuid = config.sops.placeholder."vless_uuid_${u}";
                        flow = "xtls-rprx-vision";
                        tls = {
                          enabled = true;
                          server_name = r.realityServerName;
                          reality = {
                            enabled = true;
                            public_key = r.realityPublicKey;
                            short_id = r.realityShortId;
                          };
                          utls = {
                            enabled = true;
                            fingerprint = "chrome";
                          };
                        };
                      }) sub.relays
                      ++ [
                        {
                          type = "direct";
                          tag = "direct";
                        }
                      ];
                      route = {
                        rules = [
                          { action = "sniff"; }
                          {
                            protocol = "dns";
                            action = "hijack-dns";
                          }
                          {
                            ip_is_private = true;
                            action = "route";
                            outbound = "direct";
                          }
                          {
                            domain_suffix = [
                              "bybit.com"
                              "3gppnetwork.org"
                            ];
                            action = "route";
                            outbound = "direct";
                          }
                          {
                            rule_set = [ "geosite-category-ip-geo-detect" ];
                            action = "route";
                            outbound = "direct";
                          }
                          {
                            rule_set = [ "geosite-category-ru" ];
                            action = "route";
                            outbound = "direct";
                          }
                          {
                            rule_set = [ "geoip-ru" ];
                            action = "route";
                            outbound = "direct";
                          }
                        ];
                        rule_set = [
                          {
                            tag = "geosite-category-ip-geo-detect";
                            type = "remote";
                            format = "binary";
                            url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ip-geo-detect.srs";
                            download_detour = "direct";
                          }
                          {
                            tag = "geosite-category-ru";
                            type = "remote";
                            format = "binary";
                            url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ru.srs";
                            download_detour = "direct";
                          }
                          {
                            tag = "geoip-ru";
                            type = "remote";
                            format = "binary";
                            url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-ru.srs";
                            download_detour = "direct";
                          }
                        ];
                        auto_detect_interface = true;
                        final = "select";
                        default_domain_resolver = "bootstrap-dns";
                      };
                    };
                  };
                }) cfg.vpnUsers
              );

            services.nginx.virtualHosts."${sub.domain}" = {
              forceSSL = true;
              enableACME = true;
              listen = httpsListen;
              root = "/var/lib/nginx/subscription";
              extraConfig = ''
                add_header X-Robots-Tag "noindex, nofollow" always;
              '';
              locations."~ ^/([a-f0-9]+)/sing-box$".extraConfig = ''
                default_type application/json;
                try_files /$1/sing-box/config =404;
              '';
              locations."~ ^/([a-f0-9]+)/qr$".extraConfig = ''
                default_type text/html;
                try_files /$1/index.html =404;
              '';
              locations."~ ^/([a-f0-9]+)/?$".extraConfig = ''
                default_type text/plain;
                add_header profile-update-interval "24";
                try_files /$1/base64 =404;
              '';
            };

            systemd.services.subscription-generator = {
              description = "Generate VPN subscription files";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
              path = [
                pkgs.coreutils
                pkgs.qrencode
              ];
              script = ''
                DEST="/var/lib/nginx/subscription"
                STAGE=$(mktemp -d "$DEST.XXXXXX")
                ${lib.concatMapStringsSep "\n" (u: ''
                    USER_TOKEN=$(sha256sum ${config.sops.secrets."vless_uuid_${u}".path} | cut -c1-32)
                    BASE="$STAGE/$USER_TOKEN"
                    mkdir -p "$BASE/sing-box"
                    base64 -w 0 ${config.sops.templates."subscription-${u}".path} > "$BASE/base64"
                    cp ${config.sops.templates."sing-box-client-${u}.json".path} "$BASE/sing-box/config"
                    SUB_URL="https://${sub.domain}/$USER_TOKEN/"
                    SINGBOX_URL="sing-box://import-remote-profile?url=https://${sub.domain}/$USER_TOKEN/sing-box#${u}"
                    qrencode -t SVG -o "$BASE/qr-sub.svg" "$SUB_URL"
                    qrencode -t SVG -o "$BASE/qr-singbox.svg" "$SINGBOX_URL"
                    cat > "$BASE/index.html" <<HTMLEOF
                  <!DOCTYPE html>
                  <html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
                  <title>${u}</title>
                  <style>body{display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#111;color:#fff;font-family:system-ui;padding:2em 0}.qr{text-align:center;margin:1.5em 0}img{width:min(500px,90vw)}a{color:#7af;font-size:0.85em;word-break:break-all}h3{margin:0.5em 0;font-weight:400;opacity:0.7}</style>
                  </head><body>
                  <h2>${u}</h2>
                  <div class="qr"><h3>Universal</h3><img src="qr-sub.svg" alt="QR"><br><a href="$SUB_URL">$SUB_URL</a></div>
                  <div class="qr"><h3>sing-box</h3><img src="qr-singbox.svg" alt="QR"><br><a href="$SINGBOX_URL">$SINGBOX_URL</a></div>
                  </body></html>
                  HTMLEOF
                    echo "${u} $USER_TOKEN" >> "$STAGE/tokens.txt"
                '') cfg.vpnUsers}
                chown -R nginx:nginx "$STAGE"
                chmod -R u=rwX,go=rX "$STAGE"
                rm -rf "$DEST"
                mv "$STAGE" "$DEST"
              '';
            };
          })

        ]
      );
    };
}
