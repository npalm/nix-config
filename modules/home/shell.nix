# Zsh managed by Home Manager: completion, history and history search.
# The prompt is configured separately in prompt.nix.
{ config, ... }:

{
  programs.zsh = {
    enable = true;
    # Keep ~/.zshrc etc. in the home directory (as before).
    dotDir = config.home.homeDirectory;

    enableCompletion = true;
    autosuggestion.enable = true; # grey suggestion from history; accept with →
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true; # ↑/↓ search history for typed text

    history = {
      path = "${config.home.homeDirectory}/.zsh_history"; # existing history file
      size = 100000;
      save = 100000;
      share = true; # shared between open terminals
      extended = true; # store timestamps
      ignoreSpace = true; # commands starting with a space are not saved
      ignoreAllDups = true;
      findNoDups = true;
      expireDuplicatesFirst = true;
    };

    # Homebrew is managed outside Nix (see README); only add it when installed.
    profileExtra = ''
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    '';
  };

  # Ctrl+R: fuzzy history search, Ctrl+T: files, Alt+C: directories.
  programs.fzf.enable = true;
}
