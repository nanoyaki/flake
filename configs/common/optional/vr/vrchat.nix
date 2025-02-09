{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    startvrc
    vrcx
    vrc-get
    unityhub
    # blender
    alcom
  ];

  hm.xdg.autostart.entries = [ "${pkgs.vrcx}/share/applications/vrcx.desktop" ];
}
