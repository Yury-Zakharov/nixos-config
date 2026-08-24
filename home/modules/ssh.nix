{ config, pkgs, lib, ... }:

{
  # SSH configuration — single owner, gpg-agent + YubiKey only, zero local keys
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "no";
      };

      "github.com" = {
        User = "git";
      };
      # Personal hosts live in ssh-private.nix (gitignored)
    };
  };

  # GPG agent with SSH support via YubiKey (ed25519 auth slot)
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 3600;
    maxCacheTtl = 28800;
    defaultCacheTtlSsh = 3600;
    maxCacheTtlSsh = 28800;
  };

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
  };
}
