{pkgs, ...}: {
  home.packages = with pkgs; [
    # Image manipulation
    imagemagick
    gimp
  ];
}
