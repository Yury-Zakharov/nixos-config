{ ... }:

let
  identity = {
    name  = "Yury Zakharov";
    email = "colonelcolt@gmail.com";
    signingKey = "8DB60D8EF257AF10";
  };
in
{
  programs.git = {
    enable = true;

    # Identity + strong GPG signing (your existing setup)
    settings.user = {
      name = identity.name;
      email = identity.email;
    };

    signing = {
      signByDefault = true;
      key = identity.signingKey;
    };

    settings = {
      # Branching policy — matches your existing config
      init.defaultBranch = "master";
      push.autoSetupRemote = true;

      # === Modern safe defaults (most popular in 2025–2026 community dotfiles) ===
      pull.rebase = true;          # git pull = rebase instead of merge (cleaner history)
      rebase.autoStash = true;     # automatically stash/unstash dirty worktree during rebase
      rebase.autosquash = true;    # auto-squash fixup! commits in interactive rebase

      fetch.prune = true;          # automatically remove deleted remote branches on fetch
      fetch.pruneTags = true;

      # Better conflict resolution
      merge.conflictStyle = "zdiff3";   # shows original base in conflicts (easier to resolve)
      rerere.enabled = true;            # reuse recorded resolutions of previous merge conflicts

      # Improved diffs
      diff.algorithm = "histogram";     # better at detecting moved code
      diff.colorMoved = "zebra";        # highlights moved lines with zebra pattern

      # General UX
      color.ui = "auto";
      status.showUntrackedFiles = "all";
      core.autocrlf = "input";          # best practice for Linux (no Windows line-ending surprises)

      # Signing (exact match to your old ~/.config/git/config)
      commit.gpgSign = true;
      tag.gpgSign = true;
    };

    # Common useful aliases (minimal popular set)
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };

    # Global .gitignore — single declaration site, reproducible
    ignores = [
      ".env"
      ".direnv/"
      ".env.*"
      "*.log"
      "*.swp"
      "*.swo"
      ".DS_Store"
      "node_modules/"
      ".idea/"
      ".vscode/"
      "*.pyc"
      "__pycache__/"
    ];
  };
}
