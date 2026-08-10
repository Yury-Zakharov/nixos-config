{ pkgs }:

pkgs.splix.overrideAttrs (old: {
  pname = "splix-m2026";
  version = "patches-2024-03-31";

  src = pkgs.fetchFromGitLab {
    owner = "ScumCoder";
    repo = "splix";
    rev = "1128dbda";
    hash = pkgs.lib.fakeHash;
  };
})
