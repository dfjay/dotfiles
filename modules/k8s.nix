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
    };
}
