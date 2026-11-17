# AI command-line tools from nixpkgs-unstable (they change too fast for stable).
# `pkgs-unstable` is created in flake.nix with only github-copilot-cli allowed as unfree.
{ pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    codex # OpenAI Codex CLI
    github-copilot-cli
    apm-cli # Agent Package Manager (microsoft/apm), command: apm
  ];
}
