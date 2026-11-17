# Nix daemon settings: use Lix explicitly.
{ pkgs, lib, ... }:

{
  # Microsoft's Dev Containers extension is distributed under an unfree license.
  nixpkgs.config.allowUnfreePredicate =
    pkg: lib.getName pkg == "vscode-extension-ms-vscode-remote-remote-containers";

  nix.package = pkgs.lix;
  nix.settings.experimental-features = "nix-command flakes";
}
