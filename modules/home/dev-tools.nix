# Basic developer tooling, with selected tools from unstable.
{ pkgs, pkgs-unstable, ... }:

{
  programs.gh = {
    enable = true;
    # gh extensions managed by Nix (instead of `gh extension install`).
    extensions = [
      pkgs-unstable.gh-actions-lock # gh actions-lock: GitHub Actions lockfile
    ];
  };

  home.packages = with pkgs; [
    nodejs
    pkgs-unstable.devcontainer # Dev Containers CLI: `devcontainer up --workspace-folder .`
    jq
    ripgrep
    pre-commit # per-repo hooks: `pre-commit install` in a repo with .pre-commit-config.yaml
  ];
}
