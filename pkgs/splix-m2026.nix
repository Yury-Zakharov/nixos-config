{ pkgs }:

pkgs.splix.overrideAttrs (old: {
  pname = "splix-m2026";
  version = "patches-2024-03-31";

  src = pkgs.fetchFromGitLab {
    owner = "ScumCoder";
    repo = "splix";
    rev = "1128dbda";
    hash = "sha256-VTfLaD97/WAaRSYcQEbPE9BNmIfANigl10GxgFQdi/8=";
  };

  postPatch = pkgs.lib.replaceStrings
    [ "mv -v *.ppd ppd/\n" ]
    [ "" ]
    old.postPatch;
})
