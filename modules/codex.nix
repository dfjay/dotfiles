{
  homeModule =
    { lib, ... }:
    {
      programs.codex = {
        enable = true;
        enableMcpIntegration = true;
        mutableSettings = true;
        settings = {
          default_permissions = "workspace-guarded";
          approval_policy = "on-request";
          approvals_reviewer = "auto_review";

          permissions.workspace-guarded = {
            extends = ":workspace";
            filesystem = lib.genAttrs [
              "~/.netrc"
              "~/.ssh"
              "~/.gnupg"
              "~/.password-store"
              "~/.local/share/gopass"
              "~/.config/sops"
              "~/.config/sops-nix"
              "~/.config/gh/hosts.yml"
              "~/.config/glab-cli"
            ] (_: "deny");
          };
        };
      };
    };
}
