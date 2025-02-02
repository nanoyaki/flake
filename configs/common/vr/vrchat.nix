{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    startvrc
    vrcx
    vrc-get
    unityhub
    blender
  ];
}
