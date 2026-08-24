{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/identity.nix
    ./modules/secrets.nix
    ./modules/ssh.nix
    ./modules/shell.nix
    ./modules/direnv.nix
  ] ++ lib.optional (builtins.pathExists ./modules/ssh-private.nix) ./modules/ssh-private.nix;

  home.username = "yury";
  home.homeDirectory = "/home/yury";
  home.stateVersion = "25.11";

  # Core user packages — single declaration site
  home.packages = with pkgs; [
    nix-prefetch-scripts
    git
    gh
    jq
    kdePackages.kpat
    zed-editor
    jetbrains.rider

    (pkgs.writeShellScriptBin "riderw" ''
      set -euo pipefail
      if [ -z "''${DIRENV_DIR:-}" ]; then
        echo "ERROR: direnv is not active in this shell."
        echo "cd into the project directory first."
        exit 1
      fi
      exec setsid rider "$@" >/dev/null 2>&1 < /dev/null &
    '')

    podman-desktop
    podman-compose
    vlc
    qbittorrent
    vlc-bittorrent
    antigravity-ide
#    zoom-us
    tor-browser
    obsidian
#    teams-for-linux
    remanager
    pdfstudioviewer
    seamly2d
  ];

  # Session variables — single declaration site
  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_DATA_HOME   = "$HOME/.local/share";
    GPG_TTY         = "$(tty)";
  };

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    profiles.default.name = "Default";
    policies = {
      DisableTelemetry = true;
      EnableTrackingProtection = true;
    };
  };

  programs.zed-editor.enable = true;
}
