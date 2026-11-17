# macOS configuration

An Apple Silicon setup using [Lix](https://lix.systems),
[nix-darwin](https://github.com/nix-darwin/nix-darwin) for system settings,
and [Home Manager](https://github.com/nix-community/home-manager) for user
software and settings. The current configuration is named `m5pro`.

## Structure

| Location | Purpose |
| --- | --- |
| `flake.nix` | Dependencies and device configurations |
| `flake.lock` | Exact dependency versions and hashes |
| `hosts/<name>/default.nix` | System modules for a device |
| `hosts/<name>/home.nix` | User modules for a device |
| `modules/darwin/` | Shared macOS and Nix settings |
| `modules/home/` | Software, shell, Git, SSH and editor settings |
| `ci/private-example/` | Example personal values, also used by CI |
| `devshell.nix`, `.pre-commit-config.yaml`, `.github/` | Development tools and checks |

Personal values live outside the repo in `~/.config/nix-private/default.nix`.
The public flake reads them through `/etc/nix-private/default.nix`, using a
local symlink. See [device setup](docs/setup.md).

## Everyday commands

Run these from `~/.config/nix-darwin`. Choose either column.
`nh` shows a package diff and asks before activating when you use `--ask`.

| Task | With `nh` | With `darwin-rebuild` |
| --- | --- | --- |
| Build without applying | `nh darwin build` | `darwin-rebuild build --flake .#m5pro` |
| Apply changes | `nh darwin switch --ask` | `sudo darwin-rebuild switch --flake .#m5pro` |
| Update all inputs and apply | `nh darwin switch --ask --update` | `nix flake update` then the apply command above |

`nh` gets the device and repository path from `NH_DARWIN_FLAKE`, set by this
configuration. Before the first activation, pass them explicitly:
`nh darwin switch --ask .#m5pro`.

## Update software

Most software uses stable `nixpkgs` (26.05). Selected tools use
`nixpkgs-unstable`, including AI tools, Oh My Posh and the Dev Containers CLI.

To update one input, then review and apply:

```sh
nix flake update nixpkgs             # stable software
# or: nix flake update nixpkgs-unstable
# or: nix flake update               # all inputs
git diff -- flake.lock
nh darwin switch --ask
# or: sudo darwin-rebuild switch --flake .#m5pro
```

Updating the lockfile alone does not change installed software. Keep
`flake.lock` in Git with the configuration changes you tested.

Homebrew is separate. Update its apps with `brew update && brew upgrade`.

## Add or remove software

Edit the relevant module, then apply with either command above.

| Software | Where to edit |
| --- | --- |
| General developer tools | `modules/home/dev-tools.nix` |
| AI tools from unstable | `modules/home/ai-tools.nix` |
| AWS, Azure and Kubernetes tools | `modules/home/cloud-tools.nix` |
| macOS menu bar apps | `modules/home/macos-apps.nix` |
| VS Code Insiders extensions | `modules/home/vscode-insiders.nix` |
| VS Code Insiders settings | `modules/home/vscode-insiders/settings.json` |
| Ghostty | `modules/home/terminal.nix` |

For example, add `tree` to a module's `home.packages` list to install it.
Remove it from the list to uninstall it on the next switch. For software
configured with `programs.<name>.enable`, disable it or remove its module
from the host's imports. Stage new files with `git add` before building so
the flake can see them.

Unfree packages also need an allowlist entry in `flake.nix` for unstable,
or `modules/darwin/nix.nix` for stable.

VS Code Insiders and Docker Desktop are installed through Homebrew.
Use `brew install --cask <name>` or `brew uninstall --cask <name>` for those
apps. Their installation is not controlled by this flake.

## Revert a change

To return to the previous system generation, including when you normally
use `nh`:

```sh
sudo darwin-rebuild --rollback
```

The installed `nh` version has no Darwin rollback command. To select an
older generation:

```sh
sudo darwin-rebuild --list-generations
sudo darwin-rebuild --switch-generation 42   # replace 42 with the chosen number
```

A rollback changes the active system, not your source files. Restore the
affected configuration files and `flake.lock` from a known good Git commit
before the next switch. See [recovery details](docs/development.md#recovery).

## More

- [Set up a Mac or add another device](docs/setup.md)
- [SSH keys and Git signing](docs/ssh.md)
- [Development, troubleshooting and cleanup](docs/development.md)
