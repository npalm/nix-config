# Home Manager configuration for m5pro.
{ ... }:

{
  imports = [
    ../../modules/home/dev-tools.nix
    ../../modules/home/vscode-insiders.nix
    ../../modules/home/git.nix
    ../../modules/home/ai-tools.nix
    ../../modules/home/terminal.nix
    ../../modules/home/nix-tools.nix
    ../../modules/home/cloud-tools.nix
    ../../modules/home/shell.nix
    ../../modules/home/prompt.nix
    ../../modules/home/direnv.nix
    ../../modules/home/ssh.nix
    ../../modules/home/macos-apps.nix
  ];

  # Keep this value when updating packages.
  home.stateVersion = "26.05";
}
