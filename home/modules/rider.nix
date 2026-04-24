# home/modules/rider.nix
{ pkgs, ... }:

{
  home.packages = [ pkgs.jetbrains.rider ];

  # Rider stores versioned config in ~/.config/JetBrains/Rider*
  # Declare only the exact files/settings you want here (xdg.configFile).
  # Do not dump the entire directory.
}
