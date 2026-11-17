# Host m5pro: Apple Silicon MacBook (alias only; the real hostname is untouched).
{ host, ... }:

{
  imports = [
    ../../modules/darwin/nix.nix
    ../../modules/darwin/system.nix
    ../../modules/darwin/touch-id-sudo.nix
    ../../modules/darwin/ssh-known-hosts.nix
    ../../modules/darwin/shell.nix
    ../../modules/darwin/home-manager.nix
  ];

  # Used for backwards compatibility; read `darwin-rebuild changelog` before changing.
  system.stateVersion = 6;

  home-manager.users.${host.username} = ./home.nix;
}
