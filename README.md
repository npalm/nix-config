# nix-darwin configuration

macOS configuration for Apple Silicon using [Lix](https://lix.systems),
[nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[Home Manager](https://github.com/nix-community/home-manager) in one flake.

Configuration alias: `m5pro` (independent of the Mac's hostname).

## Layout

```
flake.nix                         inputs + mkDarwinHost helper + host list
flake.lock                        pinned input revisions
hosts/m5pro/default.nix           system modules for this host
hosts/m5pro/home.nix              Home Manager modules for this host
modules/darwin/nix.nix            Lix, flakes
modules/darwin/system.nix         platform, vim, user home directory
modules/darwin/touch-id-sudo.nix  Touch ID for sudo (password fallback)
modules/darwin/ssh-known-hosts.nix  pinned GitHub SSH host keys
modules/darwin/shell.nix          minimal system Zsh (no default prompt/compinit)
modules/darwin/home-manager.nix   Home Manager integration
modules/home/dev-tools.nix        gh, nodejs, jq, ripgrep, pre-commit (stable)
modules/home/git.nix              Git + personal/Philips identities (stable)
modules/home/ai-tools.nix         codex, github-copilot-cli, apm-cli (unstable)
modules/home/terminal.nix         Ghostty (ghostty-bin)          (stable)
modules/home/nix-tools.nix        nh, nixfmt, nixd               (stable)
modules/home/cloud-tools.nix      awscli2, azure-cli, kubectl, k9s (stable)
modules/home/shell.nix            Zsh: completion, history, suggestions, fzf
modules/home/prompt.nix           Oh My Posh prompt                (unstable)
modules/home/oh-my-posh/theme.omp.json  prompt theme
modules/home/ssh.nix              SSH client + Secure Enclave keys (loaded at login)
modules/home/macos-apps.nix       menu bar apps: Caffeine          (stable)
modules/home/direnv.nix           direnv + nix-direnv (`use flake` in .envrc)
devshell.nix                      dev shell for this repo: pre-commit, nixfmt,
                                  betterleaks, zizmor, gh-actions-lock (unstable)
.envrc                            loads the dev shell via direnv
.pre-commit-config.yaml           formatting, secrets, workflow hooks
.github/workflows/ci.yml          CI: pre-commit, secrets, zizmor, lockfile, eval
.github/workflows/actions.lock    pinned action commits (generated)
.github/dependabot.yml            weekly grouped action updates
```

Packages come from stable `nixpkgs` (26.05) by default. Only the AI tools, the
prompt and betterleaks use `nixpkgs-unstable` (`pkgs-unstable`).

## Homebrew (managed outside Nix)

Homebrew is only for apps nixpkgs cannot provide on macOS, and is not
managed by this flake. Install it with the official script:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# PATH setup is in modules/home/shell.nix (profileExtra)
```

Apps currently installed via Homebrew:

```sh
brew install --cask visual-studio-code@insiders docker-desktop
```

Check nixpkgs first (`nix search nixpkgs <name>`) before adding a cask, and
keep the list above up to date.

## Basic operations

> If `sudo darwin-rebuild` reports "command not found", open a new terminal
> (older shells may lack nix-darwin's PATH) or use the full path
> `/run/current-system/sw/bin/darwin-rebuild`.

```sh
cd ~/.config/nix-darwin

# Build without activating (no sudo needed)
darwin-rebuild build --flake .#m5pro

# Apply the configuration
sudo darwin-rebuild switch --flake .#m5pro

# Roll back to the previous generation
sudo darwin-rebuild --rollback

# Alternative: build, show package diff, confirm, activate (asks for sudo itself)
nh darwin switch --ask

# Format Nix files
nixfmt flake.nix hosts/*/*.nix modules/*/*.nix

# List generations
sudo darwin-rebuild --list-generations
```

## Updating

```sh
# Only the AI tools (nixpkgs-unstable)
nix flake update nixpkgs-unstable

# A single stable input
nix flake update nixpkgs

# Everything
nix flake update
```

Homebrew apps are updated separately: `brew update && brew upgrade`
(VS Code Insiders and Docker Desktop also update themselves).

Then build and apply as above. Revert a bad update by restoring the previous
`flake.lock` and rebuilding, or by rolling back.

## Shell

- `→` accepts the grey suggestion; `↑`/`↓` search history for what you typed.
- `Ctrl+R` fuzzy history search, `Ctrl+T` files, `Alt+C` directories (fzf).
- Start a command with a space to keep it out of history.
- Prompt theme: edit `modules/home/oh-my-posh/theme.omp.json`, or switch to a
  built-in theme with `useTheme` in `modules/home/prompt.nix`.
- Startup time: `time zsh -i -c exit`.

`~/.zshrc`, `~/.zprofile` and `~/.zshenv` are generated; change them here.

## Working on this repo (direnv + pre-commit)

Entering this directory loads the dev shell (`devshell.nix`) via direnv; tools
there (betterleaks, nixfmt, pre-commit) are project-only. First time only:

```sh
cd ~/.config/nix-darwin && direnv allow     # or without direnv: nix develop
```

Once this is a Git repository, the dev shell installs the pre-commit hook
automatically. Each commit then runs:

- basic checks (whitespace, end of file, YAML/JSON, merge markers, large files)
- `nixfmt` on staged `.nix` files (failing commits are fixed; re-add and commit)
- `betterleaks` on the staged changes (blocks commits containing secrets;
  output is redacted)
- `zizmor --persona pedantic --offline` on workflows and config
- `gh-actions-lock --verify-local`: every `uses:` must be in `actions.lock`

```sh
pre-commit run --all-files                  # run all hooks manually
betterleaks dir . --redact                  # full scan of the working tree
pre-commit autoupdate --freeze              # update pinned hook revisions
gh actions-lock                             # (re)generate actions.lock after editing `uses:`
zizmor --persona pedantic .                 # full audit incl. online checks (needs GH_TOKEN)
nix flake update nixpkgs-unstable           # newer betterleaks (also updates AI tools)
```

CI (`.github/workflows/ci.yml`, on push to `main` and PRs) runs the hooks,
a betterleaks scan of the full history, online zizmor, `gh actions-lock
--verify`, and evaluates `darwinConfigurations.m5pro` (eval only, Linux
runner). The `gh actions-lock` extension is installed globally via
`programs.gh.extensions` in `modules/home/dev-tools.nix`.

Nix flakes only see files tracked by Git: `git add` new files
before building.

## Private values

Email addresses, the local username and home directory are not in this
(public) repo. They live in `~/.config/nix-private/default.nix`, read as
the flake input `private` (see `flake.nix`). The input URL and lockfile
use `/etc/nix-private/default.nix`, with `/etc/nix-private` a symlink to
that directory, so neither records your home path. Pointing at the file
also avoids copying unrelated files from the private directory.

This keeps personal values out of Git, but Nix copies the private input
into its locally readable store. Never put passwords, tokens or private
keys in it.

```sh
$EDITOR ~/.config/nix-private/default.nix
nix flake update private        # required: changes are ignored until the lock is updated
```

New machine: copy `ci/private-example/` to `~/.config/nix-private/` and fill
in the values, including `hosts.m5pro.username` and
`hosts.m5pro.homeDirectory`. Create the local symlink once:

```sh
sudo ln -s "$HOME/.config/nix-private" /etc/nix-private
nix flake update private
```

`nh darwin switch --ask` continues to work:
its configuration path is generated from the private home directory.
CI uses the dummy values via `--override-input private path:./ci/private-example`.
A pre-commit hook blocks email addresses other than `example.com` and GitHub
noreply addresses (plus `@github.com` and `@openssh.com`, used in SSH addresses and key types).

## SSH keys and commit signing (Secure Enclave)

Two non-exportable Secure Enclave keys per Mac, each use needs Touch ID:
`git-signing` signs all commits/tags, `github-auth` is for SSH to GitHub
(`git@github.com:` URLs; HTTPS still uses `gh`). macOS's own OpenSSH is used.

New Mac (once, manual: keys can't be created by Nix):

1. Create the two keys (each asks for Touch ID when used):
   ```sh
   sc_auth create-ctk-identity -l git-signing -k p-256-ne -t bio
   sc_auth create-ctk-identity -l github-auth -k p-256-ne -t bio
   ```
2. Load them into the macOS ssh-agent (after activation this happens at login):
   ```sh
   ssh-add -K -S /usr/lib/ssh-keychain.dylib     # PIN prompt: press Enter
   ```
3. Find which public key belongs to which label:
   ```sh
   sc_auth list-ctk-identities -t ssh            # label -> SHA256 fingerprint
   ssh-add -L > /tmp/keys.pub; ssh-keygen -lf /tmp/keys.pub; rm /tmp/keys.pub
   ```
4. Put the matching public keys in `~/.config/nix-private/default.nix`
   (`ssh.signingKey` = git-signing, `ssh.authKey` = github-auth), then:
   ```sh
   nix flake update private && nh darwin switch --ask
   ```
5. Register both keys on GitHub:
   ```sh
   gh auth refresh -s admin:public_key,admin:ssh_signing_key
   gh ssh-key add ~/.ssh/github-auth.pub --type authentication --title "<host> secure enclave"
   gh ssh-key add ~/.ssh/git-signing.pub --type signing --title "<host> secure enclave"
   ```
   GitHub only shows "Verified" if the commit email is a verified email on
   the account (also the work email).
6. Test (not in `/tmp`):
   ```sh
   ssh-add -l                                    # two ECDSA-SK keys
   ssh -T git@github.com                         # Touch ID, then "Hi <user>!"
   mkdir -p ~/scratch/sign-test && cd ~/scratch/sign-test && git init
   git commit --allow-empty -m "signing test"    # Touch ID
   git --no-pager log --show-signature -1        # Good "git" signature ... ECDSA-SK
   ```

Agent log: `~/Library/Logs/ssh-add-secure-enclave.log`. The keys cannot be
backed up: if this Mac is replaced, create new keys and register them (old
commits stay verified).

Troubleshooting `ssh -T git@github.com` (`ssh -vT` shows the cause):
"Host key verification failed" means GitHub's host keys are missing from
`/etc/ssh/ssh_known_hosts` (see `ssh-known-hosts.nix`; source:
https://api.github.com/meta). "ignoring authenticator-hosted key" means
`SecurityKeyProvider /usr/lib/ssh-keychain.dylib` is missing for that host.
Don't test signing in `/tmp`: Git refuses it ("dubious ownership").

## Common changes

- **Add a stable package:** add it to `home.packages` in
  `modules/home/dev-tools.nix`.
- **Add a GUI app:** prefer nixpkgs (Home Manager module or `home.packages`);
  otherwise install it with Homebrew and add it to the Homebrew list above.
- **Add an AI tool:** add it to `modules/home/ai-tools.nix`. If it is
  unfree, add its name to `allowUnfreePredicate` in `flake.nix`.
- **Change Git identities:** emails live in `~/.config/nix-private`
  (see below); the rules are in `modules/home/git.nix`. The personal
  identity is the default; `philipsDirs` (`projects/github/philips-*/`, at
  any depth, recursive) selects where the Philips identity applies.
- **Add a host:** add a `mkDarwinHost { name; system; username; homeDirectory; }`
  entry in `flake.nix` and create `hosts/<name>/default.nix` and
  `hosts/<name>/home.nix` that import the modules the host needs.

## Checks

```sh
which codex copilot gh node jq rg brew code-insiders
brew list --cask
git config user.email          # default: personal email
                               # in .../projects/github/philips-*/: work email
sudo -k && sudo true           # Touch ID prompt; cancel for password fallback
```

## Cleanup

```sh
# Delete old generations and unused store paths
sudo nix-collect-garbage --delete-older-than 30d
```
