# Development shell for this repository, loaded automatically by direnv
# (see .envrc) or manually with `nix develop`. Tools here are project-only.
{ pkgs, pkgs-unstable }:

pkgs.mkShellNoCC {
  packages = [
    pkgs.pre-commit
    pkgs.nixfmt
    # Security tools from unstable for the newest rules and audits.
    pkgs-unstable.betterleaks # secret scanner
    pkgs-unstable.zizmor # GitHub Actions static analysis
    pkgs-unstable.gh-actions-lock # GitHub Actions lockfile (actions.lock)
  ];

  # Install the Git pre-commit hook once the directory is a Git repository.
  shellHook = ''
    if git rev-parse --git-dir >/dev/null 2>&1 \
      && [ ! -f "$(git rev-parse --git-path hooks)/pre-commit" ]; then
      pre-commit install
    fi
  '';
}
