{ pkgs, ... }:

{
  hms = [ { programs.git.enable = true; } ];

  programs.git = {
    enable = true;
    lfs.enable = true;

    config.init.defaultBranch = "main";
  };

  environment.systemPackages = [ pkgs.gnupg ];
}
