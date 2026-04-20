{ config, pkgs, lib, ... }:

{
  programs.password-store.enable = true;
  programs.gpg.enable = true;

  home.sessionVariables = {
    SECRETS_BACKEND = "pass";
    PASS_ENABLE_EXTENSIONS = "true";
    SECRETS_DIR = "$HOME/.secrets";
  };

  home.file.".password-store/.gpg-id".text = "E9B35F76175913AB\n";
}
