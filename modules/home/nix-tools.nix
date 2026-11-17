# Tools for working on Nix code and this configuration (stable nixpkgs).
{ pkgs, ... }:

{
  # `nh darwin switch` builds, shows a diff of changed packages and activates.
  # Its flake path (NH_DARWIN_FLAKE) is set system-wide in modules/darwin/system.nix,
  # because Home Manager session variables need a Home Manager-managed shell.
  programs.nh.enable = true;

  home.packages = with pkgs; [
    nixfmt # official Nix formatter
    nixd # Nix language server (e.g. for the VS Code Nix IDE extension)
  ];
}
