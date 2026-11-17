# Development and recovery

## Work on the configuration

The dev shell provides formatting, secret scanning and workflow checks.
Load it with either command:

```sh
direnv allow   # once per checkout; loads automatically after that
# or: nix develop
```

The shell installs a Git pre-commit hook. Before committing:

```sh
nixfmt flake.nix hosts/*/*.nix modules/*/*.nix
pre-commit run --all-files
betterleaks dir . --redact
```

Stage new files before building. Git-backed flakes do not include untracked
files. Edit the Nix source rather than generated files such as `~/.zshrc`.

Hooks check formatting, common file errors, secrets, email addresses and
workflow security. CI also scans Git history, audits workflows online,
verifies action locks and evaluates `m5pro` with dummy private values.
CI does not build or activate macOS software.

To run the same evaluation locally without personal values:

```sh
nix eval --no-write-lock-file \
  --override-input private path:./ci/private-example \
  --raw .#darwinConfigurations.m5pro.system.drvPath
```

For maintenance of the checks themselves:

```sh
pre-commit autoupdate --freeze  # update pinned hook revisions
gh actions-lock                # regenerate after changing workflow actions
zizmor --persona pedantic .     # online audit; needs GH_TOKEN
```

## Recovery

Use `sudo darwin-rebuild --rollback` for an immediate system rollback.
To make the fix last, restore the relevant source files and lockfile from
a known good commit. For example, to undo only a dependency update:

```sh
git log --oneline -- flake.lock
# Replace <good-commit> with the chosen revision. This overwrites local
# changes to flake.lock, so review or save them first.
git restore --source=<good-commit> -- flake.lock
nh darwin switch --ask
# or: sudo darwin-rebuild switch --flake .#m5pro
```

If configuration files changed too, restore those from the same revision.
The private file is separate from Git: restoring an older lockfile may
require restoring the matching private values as well, or running
`nix flake update private` to use your current values.

If `sudo darwin-rebuild` is not found, open a new terminal or use
`sudo /run/current-system/sw/bin/darwin-rebuild`.

## Shell and editor

- Start a command with a space to keep it out of shell history.
- Right arrow accepts a shell suggestion; up and down search history.
- `Ctrl+R` searches history, `Ctrl+T` selects a file, `Alt+C` selects a directory.
- Change the prompt in `modules/home/prompt.nix` and
  `modules/home/oh-my-posh/theme.omp.json`.
- VS Code Insiders settings and host extensions are managed under
  `modules/home/vscode-insiders*`. Add container tools in each project's
  `devcontainer.json`.

## Cleanup

After confirming the system works, remove generations older than 30 days
and collect unused store paths:

```sh
sudo nix-collect-garbage --delete-older-than 30d
```

Deleted generations are no longer available for a quick rollback. Removing
a package from the configuration does not immediately delete its store
files or the application's user data.

## References

- [Lix lockfile updates](https://docs.lix.systems/manual/lix/stable/command-ref/new-cli/nix3-flake-update.html)
- [nix-darwin rebuild command](https://github.com/nix-darwin/nix-darwin/blob/master/pkgs/nix-tools/darwin-rebuild.sh)
