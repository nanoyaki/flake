{ pkgs, config, ... }:

{
  hms = [ { programs.git.enable = true; } ];

  programs.git = {
    enable = true;
    lfs.enable = true;

    config.init.defaultBranch = "main";
  };

  environment.systemPackages = [ pkgs.gnupg ];

  hm = {
    sops.secrets.github-token.sopsFile = config.config'.sops.sharedSopsFile;
    sops.templates.".git-credentials" = {
      content = "https://nanoyaki:${config.hm.sops.placeholder.github-token}@github.com";
      path = "${config.hm.home.homeDirectory}/.git-credentials";
      mode = "400";
    };
  };
}
