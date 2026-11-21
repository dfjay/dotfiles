{
  homeModule =
    { pkgs, ... }:

    {
      home.packages = with pkgs; [
        helm-ls
        k3d
        kubectl
        kubelogin-oidc
        kubecm
        kubernetes-helm
      ];

      programs.k9s = {
        enable = true;
      };

      programs.zed-editor = {
        extensions = [ "helm" ];
        userSettings.file_types.Helm = [
          "**/templates/**/*.tpl"
          "**/templates/**/*.yaml"
          "**/templates/**/*.yml"
          "**/helmfile.d/**/*.yaml"
          "**/helmfile.d/**/*.yml"
          "**/values*.yaml"
        ];
      };
    };
}
