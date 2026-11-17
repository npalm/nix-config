# Ghostty terminal (stable nixpkgs). `ghostty` is Linux-only; `ghostty-bin` is
# the official macOS build. Home Manager copies the app to
# ~/Applications/Home Manager Apps, where Spotlight can find it.
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;

    # Built-in themes: `ghostty +list-themes`
    settings = {
      theme = "GitHub Dark";
      cursor-style-blink = true;
    };
  };
}
