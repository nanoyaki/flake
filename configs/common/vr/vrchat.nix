{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    startvrc
    vrcx
    vrc-get
    unityhub
    blender
  ];

  hm.xdg.autostart.entries = [ "${pkgs.vrcx}/share/applications/vrcx.desktop" ];
}
