# Cloud and Kubernetes command-line tools (stable nixpkgs).
# Only the binaries are installed; credentials and kubeconfigs stay unmanaged.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    awscli2
    azure-cli
    kubectl
    k9s
  ];
}
