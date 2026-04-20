{ config, pkgs, lib, ... }:

{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;

    config = {
      whitelist.prefix = [ "$HOME/dev" ];
      disable_stdin = true;
      warn_timeout = "2s";
    };
  };
}
