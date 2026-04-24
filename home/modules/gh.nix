# home/modules/gh.nix
{ ... }:

{
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  # hosts.yml is not yet HM-managed → make it declarative here
  home.file.".config/gh/hosts.yml" = {
    text = ''
      github.com:
          git_protocol: ssh
          users:
              Yury-Zakharov:
          user: Yury-Zakharov
    '';
  };
}
