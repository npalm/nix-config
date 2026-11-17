# SSH keys and Git signing

This setup uses macOS OpenSSH and two Secure Enclave keys:

- `github-auth` authenticates SSH connections to GitHub.
- `git-signing` signs commits and tags.

Keys are created manually on each Mac and require Touch ID when used.
The configuration loads them into the SSH agent at login. HTTPS GitHub
authentication is handled separately by `gh`.

## Create keys

These commands require macOS 26 or later:

```sh
sc_auth create-ctk-identity -l git-signing -k p-256-ne -t bio
sc_auth create-ctk-identity -l github-auth -k p-256-ne -t bio
ssh-add -K -S /usr/lib/ssh-keychain.dylib
```

Press Enter if `ssh-add` asks for a PIN. Match labels to public keys by
comparing their SHA256 fingerprints:

```sh
sc_auth list-ctk-identities -t ssh
ssh-add -L
ssh-add -L | ssh-keygen -lf -
```

Copy the full public keys into `~/.config/nix-private/default.nix`:
`ssh.signingKey` for `git-signing`, and `ssh.authKey` for `github-auth`.
On a new Mac, finish [device setup](setup.md) before continuing below.
For an existing installation, update and apply:

```sh
nix flake update private
nh darwin switch --ask
# or: sudo darwin-rebuild switch --flake .#m5pro
```

## Register on GitHub

Activation creates the public key files used below:

```sh
gh auth refresh -s admin:public_key,admin:ssh_signing_key
gh ssh-key add ~/.ssh/github-auth.pub --type authentication --title "Mac secure enclave"
gh ssh-key add ~/.ssh/git-signing.pub --type signing --title "Mac secure enclave"
```

The commit email must also be verified on GitHub for a signed commit to
show as verified. Commit emails are public metadata even when configured
through the private file.

Test authentication and signing in a directory you own:

```sh
ssh -T git@github.com
mkdir -p ~/scratch/sign-test
cd ~/scratch/sign-test
git init
git commit --allow-empty -m "signing test"
git log --show-signature -1
```

## Troubleshooting

- Run `ssh -vT git@github.com` for connection details.
- For host key errors, check `/etc/ssh/ssh_known_hosts` and
  `modules/darwin/ssh-known-hosts.nix`. Compare with
  [GitHub's published fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints).
- For "ignoring authenticator-hosted key", check that the GitHub SSH
  configuration sets `SecurityKeyProvider /usr/lib/ssh-keychain.dylib`.
- Agent startup errors are logged in
  `~/Library/Logs/ssh-add-secure-enclave.log`.

Private keys cannot be exported or backed up. On a replacement Mac,
create and register new keys.
