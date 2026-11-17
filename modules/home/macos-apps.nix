# Small macOS menu bar apps (stable nixpkgs). Home Manager copies them to
# ~/Applications/Home Manager Apps, where Spotlight can find them.
# On the command line, macOS's own /usr/bin/caffeinate does the same job.
{ pkgs, ... }:

{
  home.packages = [
    pkgs.caffeine # keep the Mac awake from the menu bar
  ];
}
