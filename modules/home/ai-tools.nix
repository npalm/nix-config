# AI command-line tools, mostly from nixpkgs-unstable.
# `pkgs-unstable` is created in flake.nix with only github-copilot-cli allowed as unfree.
{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    codex # OpenAI Codex CLI
    github-copilot-cli
    apm-cli # Agent Package Manager (microsoft/apm), command: apm
    (pkgs.callPackage ../../packages/openshell.nix { }) # upstream CLI; gateway setup is separate
  ];
}
