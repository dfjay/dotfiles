{
  homeModule =
    {
      config,
      pkgs-master,
      ...
    }:
    {
      sops.secrets.context7_api_key = { };

      sops.templates."codex-config.toml" = {
        path = "${config.home.homeDirectory}/.codex/config.toml";
        content = ''
          [mcp_servers.context7]
          url = "https://mcp.context7.com/mcp"
          enabled = true

          [mcp_servers.context7.http_headers]
          CONTEXT7_API_KEY = "${config.sops.placeholder.context7_api_key}"
        '';
      };

      programs.codex = {
        enable = true;
        package = pkgs-master.codex;
      };
    };
}
