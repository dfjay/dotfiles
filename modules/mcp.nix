{
  homeModule =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      intellijUrl = "http://127.0.0.1:64342/stream";
    in
    {
      sops.secrets.context7_api_key.sopsFile = ../secrets/personal.yaml;

      programs.zed-editor.userSettings.context_servers.intellij = {
        source = "http";
        url = intellijUrl;
        enabled = false;
      };

      programs.mcp = {
        enable = true;
        servers = {
          intellij.url = intellijUrl;
          context7 = {
            command = lib.getExe pkgs.context7-mcp;
            env.CONTEXT7_API_KEY.file = config.sops.secrets.context7_api_key.path;
          };
        };
      };

      home.file.".ai/mcp/mcp.json".source = (pkgs.formats.json { }).generate "jetbrains-mcp.json" {
        mcpServers = lib.mapAttrs (
          name: server:
          lib.hm.mcp.transformMcpServer {
            inherit server;
            extraTransforms = [ (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; }) ];
            exclude = [ "enabled" ];
          }
        ) (lib.filterAttrs (name: _: name != "intellij") config.programs.mcp.servers);
      };
    };
}
