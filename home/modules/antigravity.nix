# home/modules/antigravity.nix
{ pkgs, ... }:

{
  home.packages = [ pkgs.antigravity ];

  home.file.".config/Antigravity/User/settings.json" = {
    text = builtins.toJSON {
      "json.schemaDownload.enable" = true;
      "workbench.colorTheme" = "Default Light Modern";
    };
    force = true;
  };
}
