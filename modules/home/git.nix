# Git (stable nixpkgs, default branch `main`) with the personal identity as
# default and the Philips identity for repositories under any
# `projects/github/philips-*/` directory.
# Email addresses and the signing key come from the private input (see flake.nix).
# Only commit identity is set here; authentication, credentials, SSH keys and
# remotes are untouched.
{ private, ... }:

let
  # A gitdir pattern without a leading `/` or `~/` gets `**/` prepended by Git,
  # so this matches e.g. ~/projects/github/philips-foo/ and
  # /projects/github/philips-foo/. The trailing slash makes it recursive.
  # Anchor it with `~/` (e.g. "~/projects/github/philips-*/") to be stricter.
  philipsDirs = "projects/github/philips-*/";

  # Lets `git log --show-signature` verify commits signed with our key.
  allowedSigners = ''
    ${private.git.personalEmail} namespaces="git" ${private.ssh.signingKey}
    ${private.git.workEmail} namespaces="git" ${private.ssh.signingKey}
  '';
in
{
  programs.git = {
    enable = true;

    # Sign commits and tags with the Secure Enclave key `git-signing` (Touch ID),
    # through the macOS ssh-agent (see modules/home/ssh.nix). macOS's own
    # ssh-keygen is used: it works with Apple's Secure Enclave provider.
    signing = {
      format = "ssh";
      key = "key::${private.ssh.signingKey}";
      signByDefault = true;
      signer = "/usr/bin/ssh-keygen";
    };

    settings = {
      user = {
        name = "Niek Palm";
        email = private.git.personalEmail;
      };
      init.defaultBranch = "main";
      gpg.ssh.allowedSignersFile = "${builtins.toFile "allowed_signers" allowedSigners}";
    };

    # Included after the defaults, so these values win inside philipsDirs.
    includes = [
      {
        condition = "gitdir:${philipsDirs}";
        contents.user = {
          name = "Niek Palm";
          email = private.git.workEmail;
        };
      }
    ];
  };
}
