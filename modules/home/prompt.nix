# Prompt: Oh My Posh from nixpkgs-unstable (prompt engines change quickly).
{ lib, pkgs-unstable, ... }:

{
  programs.oh-my-posh = {
    enable = true;
    package = pkgs-unstable.oh-my-posh;
    enableZshIntegration = true;

    # Based on the built-in `night-owl` theme (oh-my-posh, MIT License),
    # with the memory (sysinfo) and time segments removed and nix-shell and
    # battery segments added. Built-in themes:
    # replace `settings` with e.g. `useTheme = "atomic";`.
    settings = lib.importJSON ./oh-my-posh/theme.omp.json;
  };
}
