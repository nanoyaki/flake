{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (config.lib) nixGL;

  vrcSwitch = pkgs.writeShellScriptBin "vrcSwitch" ''
    if systemctl --user is-active monado.service --quiet;
    then PRESSURE_VESSEL_FILESYSTEMS_RW="$XDG_RUNTIME_DIR/wivrn/comp_ipc" ${lib.getExe pkgs.startvrc} "$@";
    else ${lib.getExe pkgs.startvrc} "$@";
    fi
  '';
in

{
  nixpkgs.overlays = [
    (_: prev: lib.mapAttrs (_: pkg: nixGL.wrap pkg) { inherit (prev) alcom blender unityhub; })
  ];

  home = {
    packages = with pkgs; [
      startvrc
      vrcSwitch
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
