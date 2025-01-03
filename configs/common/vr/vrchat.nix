{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    startvrc
    vrc-get
    unityhub
    blender
  ];
}
