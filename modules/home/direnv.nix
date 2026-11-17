# direnv + nix-direnv: entering a directory with an `.envrc` containing
# `use flake` loads that project's dev shell (and caches it).
# Allow each project once with `direnv allow`.
{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true; # no "direnv: loading/export" lines on every cd
  };
}
