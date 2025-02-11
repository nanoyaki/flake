{ pkgs, config, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      alcom = prev.alcom.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
        postInstall =
          oldAttrs.postInstall or ""
          + ''
            wrapProgram "$out/bin/alcom" --set GTK_USE_PORTAL 0 
          '';
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    startvrc
    vrcx
    vrc-get
    unityhub
    # blender
    alcom
  ];

  hm.home.symlinks.".local/share/Steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat" =
    "${config.hm.xdg.userDirs.pictures}/VRChat";

  environment.sessionVariables.GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";

  hm.xdg.autostart.entries = [ "${pkgs.vrcx}/share/applications/vrcx.desktop" ];
}
