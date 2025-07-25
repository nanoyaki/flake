{
  pkgs,
  config,
  ...
}:

{
  nixpkgs.overlays = [
    (_: _: {
      vrSwitch = pkgs.writeShellScriptBin "vrSwitch" ''
        if systemctl --user is-active monado.service --quiet;
        then PRESSURE_VESSEL_FILESYSTEMS_RW="$XDG_RUNTIME_DIR/monado_comp_ipc" exec "$@";
        else exec "$@";
        fi
      '';
    })
  ];

  environment.systemPackages = with pkgs; [
    startvrc
    vrSwitch
    vrcx
    vrc-get
    blender
    alcom
    unityhub
  ];

  xdg.mime.defaultApplications."x-scheme-handler/vcc" =
    "${pkgs.alcom}/share/applications/ALCOM.desktop";

  hm.home.symlinks."${config.hm.xdg.dataHome}/Steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat" =
    "${config.hm.xdg.userDirs.pictures}/VRChat";

  environment.sessionVariables.GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";

  hm.xdg.autostart.entries = [ "${pkgs.vrcx}/share/applications/vrcx.desktop" ];
}
