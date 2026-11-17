# Nix daemon settings: use Lix explicitly.
{ pkgs, ... }:

{
  nix.package = pkgs.lix;
  nix.settings.experimental-features = "nix-command flakes";
}
