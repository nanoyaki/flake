{ pkgs, ... }:

{
  hm.home.packages = [
    pkgs.spotify-qt
    pkgs.librespot
  ];
}
