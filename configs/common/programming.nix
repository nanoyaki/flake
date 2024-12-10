{
  pkgs,
  ...
}:

{
  hm.programs.git.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hugo
  ];

  programs.direnv.enable = true;
}
