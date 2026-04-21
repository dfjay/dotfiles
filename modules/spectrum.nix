{
  homeModule =
    {
      config,
      ...
    }:
    {
      sops.secrets.youtrack_mcp_token = { };

      sops.templates."spectrum-mcp.json" = {
        path = "${config.home.homeDirectory}/spectrum/.mcp.json";
        content = builtins.toJSON {
          mcpServers = {
            youtrack-cloud = {
              type = "http";
              url = "https://mcp-youtrack.cloud.sd";
              headers = {
                Authorization = "Bearer ${config.sops.placeholder.youtrack_mcp_token}";
              };
            };
          };
        };
      };

      home.file.".local/share/ca-certificates/spectrum.pem" = {
        force = true;
        text = ''
          -----BEGIN CERTIFICATE-----
          MIICkzCCAhmgAwIBAgIQf/y9Ocxt3TWe349KkoTs9DAKBggqhkjOPQQDAzCBijEL
          MAkGA1UEBhMCUlUxFjAUBgNVBAcTDVlla2F0ZXJpbmJ1cmcxFTATBgNVBAoTDFNw
          ZWN0cnVtRGF0YTEcMBoGA1UECxMTSW5mcmFzdHJ1Y3R1cmUgVGVhbTEuMCwGA1UE
          AxMlU3BlY3RydW1EYXRhIFByaXZhdGUgSW50ZXJuYWwgUm9vdCBDQTAeFw0yMzA4
          MzAwODAxNThaFw00ODA4MjMwODAxNThaMIGKMQswCQYDVQQGEwJSVTEWMBQGA1UE
          BxMNWWVrYXRlcmluYnVyZzEVMBMGA1UEChMMU3BlY3RydW1EYXRhMRwwGgYDVQQL
          ExNJbmZyYXN0cnVjdHVyZSBUZWFtMS4wLAYDVQQDEyVTcGVjdHJ1bURhdGEgUHJp
          dmF0ZSBJbnRlcm5hbCBSb290IENBMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEYv+S
          Fz6n7Iomq9mrL3RmqmnOd94jparmjmrBswXc0g56HYjWELfVS8E9Q+bj+BnPLogZ
          1sRLV0E5Dcbhns8HHY0hNTOFg0I7pjrvFFPdXJwu4YKxJkMUrMW73kpSsPi7o0Iw
          QDAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUDnc6
          210AfKSo9luISpIdlrEv87QwCgYIKoZIzj0EAwMDaAAwZQIxALiknFgbBW8Rwqrb
          vNODnxTukLDpALjr7zeJr60yhe/qOWouGBmkoAsfGTnbMJfIFQIwCNeZC/qoftT4
          ecDHjvnBlc27Wk2YeissBA9v/7Nwz9ruqOyIq9TqvUAC2PzQ+Wp0
          -----END CERTIFICATE-----
          -----BEGIN CERTIFICATE-----
          MIIFxzCCA6+gAwIBAgIQEUs+OYoLWbxEW+2JWL4CrzANBgkqhkiG9w0BAQsFADBq
          MQswCQYDVQQGEwJSVTEVMBMGA1UEChMMU3BlY3RydW1EYXRhMRAwDgYDVQQLEwdD
          b3JwIElUMTIwMAYDVQQDEylTcGVjdHJ1bSBMYWIgUm9vdCBDZXJ0aWZpY2F0aW9u
          IEF1dGhvcml0eTAeFw0yMzA1MzAwNTU0MzBaFw00ODA1MzAwNjA0MTlaMGoxCzAJ
          BgNVBAYTAlJVMRUwEwYDVQQKEwxTcGVjdHJ1bURhdGExEDAOBgNVBAsTB0NvcnAg
          SVQxMjAwBgNVBAMTKVNwZWN0cnVtIExhYiBSb290IENlcnRpZmljYXRpb24gQXV0
          aG9yaXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxVAl8MkU7vUx
          sQOuXSPt9rbioeHJcRjAJU7oyd9GNHdQzX74wl6HRcqmH6h8isdc2ff7j2s7ta+v
          7fbhTYS2JIS/8Yd7j1mFKEpDnErhsFZOoluIQyb8hFY8Tfbs1iThzx9kHm8cHiq3
          XqnDDDuSMlVxz5PmmioCHjS6zxooLHQl1KxWZO8tEdTOwmceo6UiJHJxWzUSJ8CF
          T6wVW32R25OVkJfnitf2zfpuyJ+8wfaqLvIhUNvTWNwHcIEBSFwOr9lO0sGwgYhF
          WLnLwM6XcrsF06bcgr/XBimD7SThRQlZk9iFfFWa5AGgvXtcAHPTM7AaFLquTaW9
          qRWCHSdgQncpGFsU+27gxyKIr95OpsC4KSydh3HDbJYceVfTMw3UgYMmEg4ygw4N
          pYBXauhzIt4vslRWS4DRU0v2WestovcsNNKWYuwCQv56uxzsrEfGmBAi5imTd0Az
          fnYBoKqLo8Fqzmysj4ZjxMyXV3SPSJCpAfH1/31f0u2Lz+Mgk/RmQ3mEhbafQ8M5
          3ptOQUvwNT/zJfLEVToR6EnK8MI8gvSS26hoNTOjYzcnWzl+KklMhndC4VzOCcfg
          PSRJbOGUS4eSPiHX4hai/9DAPFbIFeno1OgYB5FQDvVl1JCQHiBQzope3uYdbRQ3
          cvw0ZgQTB382c8Naxe7t/gYeFr0/QW0CAwEAAaNpMGcwEwYJKwYBBAGCNxQCBAYe
          BABDAEEwDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYE
          FGIfp3HwVIUWcxbuBNBrrznjqJFHMBAGCSsGAQQBgjcVAQQDAgEAMA0GCSqGSIb3
          DQEBCwUAA4ICAQCojpZWVAAM9NSu2pA06JJPRiD9Q6OhLjAVEZfQX7hC4E8RASj9
          OzgNQWhJA5qSFGoMRC/QY55AmY86a1s6vEStBk+JPPS1lVpr/1GSA/wi5pDRw8Fr
          zz1kcP1oW12bQxRSH9xgUhbAW/3FYPtEpBVzhIPL7nAe/WFWdrkQXSHw6WFrJWwg
          arNbCQ7NVQ55OrDXTnKRPa85fA3sBuP5A3NdXaiQDqASTkiVrmYSvv/fl60F9uPe
          pTUmCYaPWtRXnQwLj6LC87la8REzR53zIl44eUHHBCAKdppm7tiCQ3hhtRGCbzn7
          YPghkjUcjuc9jRBpgkTZXeBqQXNmoopREL0FTdRFDmUbgOtyX22fABXomqUuUho/
          5V5oK/5ulfbsVjE+RnZXjVhvtxh5JH9+RFgfyAL3H/GfylBR7q241lLdjK3Bfl+w
          2IO/+MWNeaabl1QYwbedZRYsi0xnI9Yy3I2vXImdl5b5gpIXm9tgFRD9wRNn59jg
          a8auRJ64I48rgmGcbqhPNpYTi/lIrorpwcReLbLq3oYlBuT+mKfiRy5FCuAzHIVH
          2NTzkVhHJNQLE75WwXZO4+lB25zeWusQKopTQXhAw3/KD8j8TnDfBHko/NDUMlM/
          3KYau08R+6C+JEdF+moYBS7Q/Z1dk99lKJHDQThgax6oTMcLJDbaVDUIrA==
          -----END CERTIFICATE-----
        '';
      };

      programs.claude-code.settings.env = {
        NODE_EXTRA_CA_CERTS = "${config.home.homeDirectory}/.local/share/ca-certificates/spectrum.pem";
      };

      programs.git.includes = [
        {
          path = "~/spectrum/.gitconfig";
          condition = "gitdir:~/spectrum/";
        }
      ];

      home.file."spectrum/.envrc".text = ''
        export GOSUMDB="sum.golang.org https://nexus.spectrumdata.tech/repository/proxy-sum-golang/"
        export GOPROXY="direct,https://nexus.spectrumdata.tech/repository/proxy-golang/,https://proxy.golang.org"
        export GONOSUMDB=*
        export GONOPROXY=
      '';

      programs.zsh.initContent = ''
        _spectrum_mcp_link() {
          [[ -f "$HOME/spectrum/.mcp.json" ]] || return 0
          [[ "$PWD" == "$HOME/spectrum"/* ]] || return 0
          [[ -d .git ]] || return 0
          [[ -e .mcp.json ]] && return 0
          ln -s "$HOME/spectrum/.mcp.json" .mcp.json 2>/dev/null || true
        }
        if (( $+functions[add-zsh-hook] )) || autoload -U add-zsh-hook 2>/dev/null; then
          add-zsh-hook chpwd _spectrum_mcp_link
          _spectrum_mcp_link
        fi
      '';
    };
}
