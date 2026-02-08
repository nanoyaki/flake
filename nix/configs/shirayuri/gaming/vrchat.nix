{ withSystem, ... }:

{
  perSystem =
    { pkgs, ... }:

    {
      packages.vrcx = pkgs.symlinkJoin {
        name = "vrcx";
        paths = [ pkgs.vrcx ];
        postBuild = ''
          cp $out/share/applications/vrcx.desktop vrcx.desktop
          substituteInPlace vrcx.desktop \
            --replace-fail 'Exec=vrcx' 'Exec=vrcx --startup'
          mv vrcx.desktop $out/share/applications/vrcx.desktop
        '';
      };
    };

  flake.overlays.vrcx =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) vrcx;
      }
    );

  flake.nixosModules.shirayuri-vrchat =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        startvrc
        vrcx
        vrc-get
        blender
        alcom
        unityhub
      ];

      xdg.mime.defaultApplications."x-scheme-handler/vcc" =
        "${pkgs.alcom}/share/applications/ALCOM.desktop";
    };

  flake.homeModules.hana-vrchat =
    { pkgs, config, ... }:

    {
      home.file."${config.xdg.dataHome}/Steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat".source =
        config.lib.file.mkOutOfStoreSymlink "${config.xdg.userDirs.pictures}/VRChat";

      xdg.autostart.entries = [ "${pkgs.vrcx}/share/applications/vrcx.desktop" ];
    };
}
