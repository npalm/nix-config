# SSH with Secure Enclave keys (macOS 26+): private keys never leave the chip,
# every use requires Touch ID. Two keys, created manually once per Mac (see
# README): `github-auth` for SSH to GitHub, `git-signing` for commit signing
# (modules/home/git.nix). Their public keys live in the private input.
#
# Uses the macOS OpenSSH (/usr/bin/ssh*), which supports Apple's Secure Enclave
# provider /usr/lib/ssh-keychain.dylib; Home Manager does not install openssh.
{ config, private, ... }:

let
  provider = "/usr/lib/ssh-keychain.dylib";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings."github.com" = {
      User = "git";
      # Public key file: ssh picks the matching key from the agent.
      IdentityFile = "~/.ssh/github-auth.pub";
      IdentitiesOnly = true;
      # Secure Enclave keys are "-sk" keys; without a provider ssh skips them.
      SecurityKeyProvider = "/usr/lib/ssh-keychain.dylib";
    };
  };

  # Public keys as files: for IdentityFile above and for registering on GitHub.
  home.file.".ssh/github-auth.pub".text = private.ssh.authKey + "\n";
  home.file.".ssh/git-signing.pub".text = private.ssh.signingKey + "\n";

  # The macOS ssh-agent forgets keys on reboot: load all Secure Enclave keys
  # at login. The "PIN" prompt is answered empty via /dev/null.
  launchd.agents.ssh-add-secure-enclave = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/ssh-add"
        "-K"
        "-S"
        provider
      ];
      RunAtLoad = true;
      StandardInPath = "/dev/null";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ssh-add-secure-enclave.log";
    };
  };
}
