# Basic system settings shared by all hosts.
{
  pkgs,
  self,
  host,
  ...
}:

{
  nixpkgs.hostPlatform = host.system;

  # Declare the existing macOS user so Home Manager gets the correct home
  # directory. The user is not in `users.knownUsers`, so nix-darwin will not
  # create, modify or delete the account.
  users.users.${host.username}.home = host.homeDirectory;

  environment.systemPackages = [ pkgs.vim ];

  # Flake and configuration used by `nh darwin switch` (loaded via /etc/zshenv).
  # The `#name` is needed because the alias differs from the Mac's hostname.
  environment.variables.NH_DARWIN_FLAKE = "${host.homeDirectory}/.config/nix-darwin#${host.name}";

  # Git revision for `darwin-version` (null when the directory is not a Git repo).
  system.configurationRevision = self.rev or self.dirtyRev or null;
}
