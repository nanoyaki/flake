{ pkgs, packages, ... }:

{
  environment.systemPackages = [
    packages.startvrc
    pkgs.vrc-get
    pkgs.unityhub
    pkgs.blender
  ];
}
