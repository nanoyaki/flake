{
  lib'',
  pkgs,
  config,
  ...
}:

{
  nixpkgs.overlays = [
    (lib''.nixGlOverlay [
      "vrcx"
      "alcom"
      "blender"
      "unityhub"
    ])
  ];

  home = {
    packages = with pkgs; [
      startvrc
      vrcx
      vrc-get
      unityhub
      blender
      alcom
    ];

    symlinks."${config.xdg.dataHome}/Steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat" =
      "${config.xdg.userDirs.pictures}/VRChat";

    sessionVariables.GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  };

  xdg = {
    mimeApps.defaultApplications."x-scheme-handler/vcc" =
      "${pkgs.alcom}/share/applications/ALCOM.desktop";
    autostart.entries = [ "${pkgs.vrcx}/share/applications/VRCX.desktop" ];
  };
}
