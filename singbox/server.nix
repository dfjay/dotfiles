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
      serverSubmodule = lib.types.submodule (
        { name, ... }:
        {
          options = {
            tag = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "Short tag of the server (e.g. fr, us)";
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
            ipv6 = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether the server can reach IPv6 destinations";
            };
            domestic = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                Server located inside Russia, used to reach RU services from abroad.
                Egress is plain direct (no WARP, no RU rejects), and clients route
                RU traffic through a separate `ru-select` selector instead of `select`.
              '';
            };
          };
        }
      );

      self = cfg.servers.${cfg.tag};

      # ── Shared helpers ──────────────────────────────────────────────────

      vlessUsers = map (u: {
        uuid = config.sops.placeholder."vless_uuid_${u}";
      }) cfg.vpnUsers;

      vlessUsersWithFlow = map (u: u // { flow = "xtls-rprx-vision"; }) vlessUsers;

      realityTls = {
        enabled = true;
        server_name = self.realityServerName;
        reality = {
          enabled = true;
          handshake = {
            server = self.realityServerName;
            server_port = 443;
          };
          private_key = config.sops.placeholder.reality_private_key;
          short_id = [ self.realityShortId ];
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

      # This server first, then the other exit servers, then domestic ones.
      otherServers = lib.partition (s: !s.domestic) (
        lib.attrValues (lib.removeAttrs cfg.servers [ cfg.tag ])
      );
      allServers = [ self ] ++ otherServers.right ++ otherServers.wrong;

      userServersFor =
        u:
        let
          allowedServers = (sub.userServers.${u} or { }).servers or null;
        in
        if allowedServers == null then
          allServers
        else
          lib.filter (s: lib.elem s.tag allowedServers) allServers;
    in
    {
      options.services.sing-box-vpn = {
        enable = lib.mkEnableOption "sing-box VPN server";

        tag = lib.mkOption {
          type = lib.types.str;
          description = "Tag of this server in `servers` (e.g. fr, us)";
        };

        servers = lib.mkOption {
          type = lib.types.attrsOf serverSubmodule;
          description = ''
            Registry of all VPN servers, keyed by tag. The entry matching `tag`
            configures this host; every entry is offered in subscriptions.
          '';
        };

        masqueradeUrl = lib.mkOption {
          type = lib.types.str;
          default = "https://${self.realityServerName}";
          defaultText = lib.literalExpression ''"https://''${servers.<tag>.realityServerName}"'';
          description = ''
            Site that Hysteria2 reverse-proxies to when authentication fails,
            so active probes see a real website instead of a bare 404.
          '';
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

        subscription = {
          enable = lib.mkEnableOption "subscription generator";

          domain = lib.mkOption {
            type = lib.types.str;
            default = "subs.dfjay.com";
            description = "Domain for subscription site";
          };

          subscribers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = cfg.vpnUsers;
            description = ''
              Users for whom subscription files are generated.
              Defaults to vpnUsers. Set explicitly to include users that
              are not accepted on this host's inbounds (e.g. routed only
              through other servers).
            '';
          };

          userServers = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule {
                options = {
                  servers = lib.mkOption {
                    type = lib.types.nullOr (lib.types.listOf lib.types.str);
                    default = null;
                    description = ''
                      Server tags to include in this user's subscription.
                      null = all servers in the registry.
                    '';
                  };
                };
              }
            );
            default = { };
            description = "Per-user filter of servers in their subscription.";
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
                hy2_obfs_password.sopsFile = cfg.sharedSecretsFile;
              }
              // lib.optionalAttrs (!self.domestic) {
                warp_private_key.sopsFile = cfg.serverSecretsFile;
                warp_ipv4.sopsFile = cfg.serverSecretsFile;
                warp_ipv6.sopsFile = cfg.serverSecretsFile;
              }
              // builtins.listToAttrs (
                map (u: {
                  name = "vless_uuid_${u}";
                  value.sopsFile = cfg.sharedSecretsFile;
                }) (lib.unique (cfg.vpnUsers ++ (lib.optionals sub.enable sub.subscribers)))
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
                  dns =
                    if self.domestic then
                      {
                        servers = [
                          {
                            tag = "yandex";
                            type = "udp";
                            server = "77.88.8.8";
                          }
                        ];
                        final = "yandex";
                        strategy = "prefer_ipv4";
                      }
                    else
                      {
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
                      masquerade = {
                        type = "proxy";
                        url = cfg.masqueradeUrl;
                        rewrite_host = true;
                      };
                      users = map (u: {
                        name = u;
                        password = config.sops.placeholder."vless_uuid_${u}";
                      }) cfg.vpnUsers;
                      tls = {
                        enabled = true;
                        server_name = self.edgeDomain;
                        certificate_path = "/var/lib/acme/${self.edgeDomain}/fullchain.pem";
                        key_path = "/var/lib/acme/${self.edgeDomain}/key.pem";
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
                        server_name = self.naiveDomain;
                        certificate_path = "/var/lib/acme/${self.naiveDomain}/fullchain.pem";
                        key_path = "/var/lib/acme/${self.naiveDomain}/key.pem";
                      };
                    }
                  ];
                  endpoints = lib.optionals (!self.domestic) [
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
                    ]
                    ++ lib.optionals (!self.domestic) [
                      # Clients dial by IP; sniff recovers the domain for domain rules.
                      { action = "sniff"; }
                      {
                        rule_set = [ "geosite-category-ru" ];
                        action = "reject";
                      }
                      {
                        rule_set = [ "geoip-ru" ];
                        action = "reject";
                      }
                    ];
                    # Pinned by flake.lock instead of fetched from GitHub at runtime.
                    rule_set = lib.optionals (!self.domestic) [
                      {
                        tag = "geosite-category-ru";
                        type = "local";
                        format = "binary";
                        path = "${pkgs.sing-geosite}/share/sing-box/rule-set/geosite-category-ru.srs";
                      }
                      {
                        tag = "geoip-ru";
                        type = "local";
                        format = "binary";
                        path = "${pkgs.sing-geoip}/share/sing-box/rule-set/geoip-ru.srs";
                      }
                    ];
                    final = if self.domestic then "direct" else "warp";
                    default_domain_resolver = if self.domestic then "yandex" else "bootstrap";
                  };
                };
              };
            };

            networking.firewall = {
              enable = true;
              logRefusedConnections = false;
              allowedTCPPorts = [
                80
                443
              ];
              allowedUDPPorts = [ 443 ];
            };

            security.acme = {
              acceptTerms = true;
              defaults.email = lib.mkDefault "mail@dfjay.com";
              certs."${self.edgeDomain}".reloadServices = [ "sing-box" ];
              certs."${self.naiveDomain}".reloadServices = [ "sing-box" ];
            };

            services.nginx = {
              enable = true;

              streamConfig =
                let
                  entries =
                    map (h: "${h} 127.0.0.1:8443;") cfg.extraStreamHosts
                    ++ lib.optional sub.enable "${sub.domain} 127.0.0.1:8443;"
                    ++ [
                      "${self.naiveDomain} 127.0.0.1:8445;"
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

              virtualHosts."${self.edgeDomain}" = {
                enableACME = true;
                listen = httpOnlyListen;
                locations."/".return = "404";
              };

              virtualHosts."${self.naiveDomain}" = {
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
                "acme-${self.edgeDomain}.service"
                "acme-${self.naiveDomain}.service"
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
                map (
                  u:
                  let
                    us = userServersFor u;
                  in
                  {
                    name = "subscription-${u}";
                    value = {
                      restartUnits = [ "subscription-generator.service" ];
                      content = builtins.concatStringsSep "\n" (
                        lib.concatMap (s: [
                          "vless://${
                            config.sops.placeholder."vless_uuid_${u}"
                          }@${s.edgeDomain}:443?encryption=none&flow=xtls-rprx-vision&type=tcp&security=reality&sni=${s.realityServerName}&fp=chrome&pbk=${s.realityPublicKey}&sid=${s.realityShortId}#${u}-${s.tag}-reality"
                          "hysteria2://${
                            config.sops.placeholder."vless_uuid_${u}"
                          }@${s.edgeDomain}:443?sni=${s.edgeDomain}&obfs=salamander&obfs-password=${config.sops.placeholder.hy2_obfs_password}#${u}-${s.tag}-hy2"
                          "naive+https://${u}:${
                            config.sops.placeholder."vless_uuid_${u}"
                          }@${s.naiveDomain}:443#${u}-${s.tag}-naive"
                        ]) us
                      );
                    };
                  }
                ) sub.subscribers
              )
              // builtins.listToAttrs (
                map (
                  u:
                  let
                    us = userServersFor u;
                    exitServers = lib.filter (s: !s.domestic) us;
                    domesticServers = lib.filter (s: s.domestic) us;
                    hasDomestic = domesticServers != [ ];
                    ruNeedsIpv4 = lib.any (s: !s.ipv6) domesticServers;

                    ruOutbound = if hasDomestic then "ru-select" else "direct";
                    ruDns = if hasDomestic then "ru-dns" else "direct-dns";

                    serverOutboundTags = s: [
                      "${s.tag}-reality"
                      "${s.tag}-hy2"
                      "${s.tag}-naive"
                    ];

                    # Routing is assembled from intent-named groups instead of
                    # one positional list. ORDER BETWEEN GROUPS IS THE CONTRACT:
                    #   alwaysDirect  -> never proxied
                    #   ruleMode      -> everything else, by geosite/geoip rules
                    # Add new rules to the group matching their intent; do not
                    # reorder the groups.
                    routePreamble =
                      lib.optional ruNeedsIpv4 {
                        ip_version = 6;
                        rule_set = [ "geoip-ru" ];
                        action = "reject";
                      }
                      ++ [
                        { action = "sniff"; }
                        {
                          protocol = "dns";
                          action = "hijack-dns";
                        }
                      ];
                    routeAlwaysDirect = [
                      {
                        ip_is_private = true;
                        action = "route";
                        outbound = "direct";
                      }
                      {
                        network = "icmp";
                        action = "route";
                        outbound = "direct";
                      }
                      {
                        domain_suffix = [ "3gppnetwork.org" ];
                        action = "route";
                        outbound = "direct";
                      }
                    ];
                    routeRuleMode = [
                      {
                        rule_set = [ "geosite-bybit" ];
                        action = "route";
                        outbound = ruOutbound;
                      }
                      {
                        rule_set = [ "geosite-category-ip-geo-detect" ];
                        action = "route";
                        outbound = "direct";
                      }
                      {
                        rule_set = [ "geosite-category-ru" ];
                        action = "route";
                        outbound = ruOutbound;
                      }
                      {
                        rule_set = [ "geoip-ru" ];
                        action = "route";
                        outbound = ruOutbound;
                      }
                    ];

                    # Same group contract for DNS, mirroring routing so a
                    # domain resolves through the same path it connects through.
                    dnsAlwaysDirect = [
                      {
                        domain_suffix = [ "3gppnetwork.org" ];
                        action = "route";
                        server = "direct-dns";
                      }
                    ];
                    dnsRuleMode =
                      lib.optional ruNeedsIpv4 {
                        rule_set = [
                          "geosite-bybit"
                          "geosite-category-ru"
                        ];
                        query_type = [ "AAAA" ];
                        action = "predefined";
                      }
                      ++ [
                        {
                          rule_set = [
                            "geosite-bybit"
                            "geosite-category-ru"
                          ];
                          action = "route";
                          server = ruDns;
                        }
                      ];
                  in
                  {
                    name = "sing-box-client-${u}.json";
                    value = {
                      restartUnits = [ "subscription-generator.service" ];
                      content = builtins.toJSON {
                        experimental = {
                          clash_api = {
                            external_controller = "127.0.0.1:9090";
                            default_mode = "Rule";
                          };
                          cache_file = {
                            enabled = true;
                            store_dns = true;
                          };
                        };
                        log = {
                          level = "info";
                          timestamp = true;
                        };
                        http_clients = [
                          {
                            tag = "proxy-http";
                            detour = "select";
                          }
                        ];
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
                          ]
                          ++ lib.optional hasDomestic {
                            tag = "ru-dns";
                            type = "udp";
                            server = "77.88.8.8";
                            detour = "ru-select";
                          };
                          rules = dnsAlwaysDirect ++ dnsRuleMode;
                          final = "proxy-dns";
                          strategy = "prefer_ipv4";
                          optimistic = true;
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
                          }
                        ];
                        outbounds = [
                          {
                            type = "selector";
                            tag = "select";
                            outbounds = lib.concatMap serverOutboundTags exitServers;
                            default = "${(builtins.head exitServers).tag}-reality";
                          }
                        ]
                        ++ lib.optional hasDomestic {
                          type = "selector";
                          tag = "ru-select";
                          outbounds = [ "direct" ] ++ lib.concatMap serverOutboundTags domesticServers;
                          default = "direct";
                        }
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
                        ]) us
                        ++ [
                          {
                            type = "direct";
                            tag = "direct";
                          }
                        ];
                        route = {
                          rules = routePreamble ++ routeAlwaysDirect ++ routeRuleMode;
                          rule_set = [
                            {
                              tag = "geosite-bybit";
                              type = "remote";
                              format = "binary";
                              url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-bybit.srs";
                            }
                            {
                              tag = "geosite-category-ip-geo-detect";
                              type = "remote";
                              format = "binary";
                              url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ip-geo-detect.srs";
                            }
                            {
                              tag = "geosite-category-ru";
                              type = "remote";
                              format = "binary";
                              url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ru.srs";
                            }
                            {
                              tag = "geoip-ru";
                              type = "remote";
                              format = "binary";
                              url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-ru.srs";
                            }
                          ];
                          auto_detect_interface = true;
                          final = "select";
                          default_http_client = "proxy-http";
                          default_domain_resolver = "bootstrap-dns";
                        };
                      };
                    };
                  }
                ) sub.subscribers
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
              # Named capture: the `if` regex below would reset $1.
              locations."~ ^/(?<token>[a-f0-9]+)/?$".extraConfig = ''
                # sing-box apps send "SFx (sing-box …)": give them the JSON
                # profile so the universal link works there too.
                if ($http_user_agent ~ "^SF[A-Z] \(sing-box") {
                  rewrite ^ /$token/sing-box last;
                }
                default_type text/plain;
                add_header profile-update-interval "24";
                try_files /$token/base64 =404;
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
                '') sub.subscribers}
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
