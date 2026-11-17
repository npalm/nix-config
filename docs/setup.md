# Device setup

These steps assume Lix and nix-darwin are already installed. For the base
installation, use the [Lix](https://lix.systems/install/) and
[nix-darwin](https://github.com/nix-darwin/nix-darwin#installing) instructions.

Keep the repository at `~/.config/nix-darwin`; the generated `nh` path uses
that location. The configuration name, such as `m5pro`, is an alias and
does not change the Mac's hostname. The macOS account must already exist.

## Personal values

On a new Mac, copy the example file from the repository:

```sh
mkdir -p ~/.config/nix-private
cp ci/private-example/default.nix ~/.config/nix-private/default.nix
$EDITOR ~/.config/nix-private/default.nix
```

Create the symlink once:

```sh
sudo ln -s "$HOME/.config/nix-private" /etc/nix-private
```

If `/etc/nix-private` already exists, check it with `ls -ld /etc/nix-private`
before changing it. It should point to your private directory.

Fill in the private file:

- `hosts.m5pro.username` and `hosts.m5pro.homeDirectory` for the local account.
- `git.personalEmail` and `git.workEmail` for commit identities.
- `ssh.authKey` and `ssh.signingKey` with this Mac's public keys. Follow
  [SSH setup](ssh.md#create-keys) to create them.

Then update the lockfile before applying:

```sh
nix flake update private
```

The public flake and lockfile record `/etc/nix-private/default.nix` and its
hash. They do not record your home path or the file's contents. Nix does
copy the file into its locally readable store, so keep passwords, tokens
and private keys out of it.

After later edits, run `nix flake update private` and apply again.
Git identity rules live in `modules/home/git.nix`: personal by default,
work for repositories under `projects/github/philips-*/`.

## Apply on a new Mac

For the existing `m5pro` configuration:

```sh
cd ~/.config/nix-darwin
nh darwin switch --ask .#m5pro
# If nh is not installed yet:
# sudo darwin-rebuild switch --flake .#m5pro
```

Open a new terminal after activation. You can then use
`nh darwin switch --ask` without specifying the flake.

Install [Homebrew](https://brew.sh/) if needed, then install its apps:

```sh
brew install --cask visual-studio-code@insiders docker-desktop
```

Its shell path is configured in `modules/home/shell.nix`.

## Add another device

Use `laptop` as an example alias:

1. Copy `hosts/m5pro/` to `hosts/laptop/`. Adjust its imported modules.
   Keep the existing state version values when copying this setup;
   they are compatibility settings, not package versions.
2. Add an entry beside `darwinConfigurations.m5pro` in `flake.nix`:

   ```nix
   darwinConfigurations.laptop = mkDarwinHost {
     name = "laptop";
     system = "aarch64-darwin";
     inherit (private.hosts.laptop) username homeDirectory;
   };
   ```

3. Add `hosts.laptop = { username = "example"; homeDirectory = "/Users/example"; };`
   to the private file on that Mac, using its actual values. Set up its
   own SSH keys and `/etc/nix-private` symlink as described above.
4. Add the same host entry with dummy values to
   `ci/private-example/default.nix`, and add a matching evaluation step
   to `.github/workflows/ci.yml` so CI checks it too.
5. Stage the new files, update the private input, then apply on that Mac:

   ```sh
   git add flake.nix hosts/laptop ci/private-example/default.nix .github/workflows/ci.yml
   nix flake update private
   nh darwin switch --ask .#laptop
   # or: sudo darwin-rebuild switch --flake .#laptop
   ```

After activation, `nh` selects `laptop` automatically. Shared module edits
affect every host that imports them; put device-specific settings under
`hosts/<name>/`.
