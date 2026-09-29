{ config, pkgs, lib, ... }:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      se = "sudoedit";
    };

    bashrcExtra = ''
      # Initialise a new dev project
      ndi() {
          nix run --refresh --no-eval-cache github:Yury-Zakharov/nix-devshell#init -- "$@"
      }

      # Reload dev project
      ndr() {
        nix flake update devshell && direnv allow
      }

      # Collect garbage
      ncg() {
        nix-collect-garbage -d && sudo nix-collect-garbage -d
      }

      # Optimise storage. Slow operation
      nso() {
        nix-store --optimise
      }

      # Fast flake + rebuild (recommended, single source of rebuild logic)
      function nuf () {
        sudo nix flake update --flake ~/nixos-config && \
        sudo nixos-rebuild switch --flake ~/nixos-config#$(hostname)
      }

      # Rebuild with optional log message (message goes only to journal)
      function nr () {
        local msg="$*"
        if [ -n "$msg" ]; then
          echo "→ Rebuilding with message: $msg"
        fi
        sudo nixos-rebuild switch --flake ~/nixos-config#$(hostname)
      }

      # Ensure gpg-agent always knows current TTY (fixes YubiKey SSH "agent refused operation")
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
    '';
  };
}
