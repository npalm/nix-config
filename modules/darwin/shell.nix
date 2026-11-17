# System-wide Zsh (/etc/zshenv, /etc/zshrc). Kept minimal: the prompt and
# completion setup are handled per user by Home Manager (modules/home/shell.nix).
{ ... }:

{
  programs.zsh = {
    enable = true;
    promptInit = ""; # no default `suse` prompt; Oh My Posh draws the prompt
    enableGlobalCompInit = false; # Home Manager runs compinit once
  };
}
