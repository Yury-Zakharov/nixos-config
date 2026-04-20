{ config, pkgs, lib, ... }:

let
  identity = {
    name  = "Yury Zakharov";
    email = "colonelcolt@gmail.com";
    signingKey = "8DB60D8EF257AF10";  # new on-card RSA2048 master key
  };
in
{
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.git = {
    enable = true;

    settings.user = {
      name = identity.name;
      email = identity.email;
    };

    settings.push = { autoSetupRemote = true; };
    settings.init = { defaultBranch = "master"; };

    signing = {
      signByDefault = true;
      key = identity.signingKey;
    };
  };

  home.sessionVariables = {
    GIT_AUTHOR_NAME  = identity.name;
    GIT_AUTHOR_EMAIL = identity.email;
    GIT_COMMITTER_NAME  = identity.name;
    GIT_COMMITTER_EMAIL = identity.email;
  };
}
