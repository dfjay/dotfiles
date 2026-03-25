{
  nixosModule =
    { ... }:
    {
      programs.zsh.enable = true;
    };

  homeModule =
    { ... }:
    {
      programs.zsh = {
        enable = true;
        autocd = false;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        sessionVariables = {

        };

        oh-my-zsh = {
          enable = true;
          plugins = [
            "docker"
            "git"
            "golang"
            "gradle"
            "helm"
            "kubectl"
            "macos"
            "npm"
            "podman"
            "rust"
            "ssh"
            "systemd"
          ];
        };

        shellAliases = {
          edit = "sudo -e";
        };

        history = {
          size = 30000;
          ignoreAllDups = true;
          ignorePatterns = [
            "rm *"
            "pkill *"
            "cp *"
          ];
        };
      };
    };
}
