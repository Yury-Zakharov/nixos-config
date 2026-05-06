# home/modules/firefox.nix
{ ... }:

{
  programs.firefox = {
    enable = true;
    profiles.default.name = "Default";
    policies = {
      DisableTelemetry = true;
      EnableTrackingProtection = true;
    };
  };
}
