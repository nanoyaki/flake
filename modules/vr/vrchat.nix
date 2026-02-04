{
  pkgs,
  config,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      vrcx = final.symlinkJoin {
        name = "vrcx";
        paths = [ prev.vrcx ];
        postBuild = ''
          cp $out/share/applications/vrcx.desktop vrcx.desktop
          substituteInPlace vrcx.desktop \
            --replace-fail 'Exec=vrcx' 'Exec=vrcx --startup'
          mv vrcx.desktop $out/share/applications/vrcx.desktop
        '';
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    startvrc
    vrcx
    vrc-get
    blender
    alcom
    # unityhub
  ];

  xdg.mime.defaultApplications."x-scheme-handler/vcc" =
    "${pkgs.alcom}/share/applications/ALCOM.desktop";

  hm.home.symlinks."${config.hm.xdg.dataHome}/Steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat" =
    "${config.hm.xdg.userDirs.pictures}/VRChat";

  hm.xdg.autostart.entries = [ "${pkgs.vrcx}/share/applications/vrcx.desktop" ];
}
