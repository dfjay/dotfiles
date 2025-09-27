{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
    kubelogin-oidc
    kubecm
    kubernetes-helm
  ];

  programs.k9s = {
    enable = true;
  };
}
