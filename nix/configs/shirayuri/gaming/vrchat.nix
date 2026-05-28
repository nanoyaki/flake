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

      packages.startvrc = pkgs.writeShellApplication {
        name = "startvrc";
        runtimeInputs = [ pkgs.inotify-tools ];
        text = ''
          # this is a wrapper script to help avoid EAC errors.

          # 1. change me
          steamapps=~/.local/share/Steam/steamapps
          watch_folder="$steamapps"/compatdata/438100/pfx/drive_c/users/steamuser/AppData/LocalLow/VRChat/VRChat

          # 2. add me to VRChat launch options:
          # /path/to/startvrc.sh %command%
          # (place any extra env vars before startvrc)

          # 3. launch vrc
          # special thanks: openglfreak

          do_taskset() {
            log=$(inotifywait --include '.*\.txt' --event create "$watch_folder" --format '%f')

            echo "Log: $watch_folder/$log"

            while ! pid=$(pgrep VRChat); do
              sleep 0.1
            done

            echo "Setting VRChat to dual-core..."
            taskset -pac 0,1 "$pid"

            tail -f "$watch_folder/$log" 2>/dev/null | sed -n '/EOS Login Succeeded/{p;q}'
            sleep 1

            echo "Setting VRChat to all cores..."
            taskset -pac "0-$(($(nproc) - 1))" "$pid"

            echo "Our work here is done."
          }

          LD_PRELOAD=''' do_taskset </dev/null &
          exec "$@"
        '';
      };
    };

  flake.overlays.vrcx =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) vrcx startvrc;
      }
    );

  flake.nixosModules.shirayuri-vrchat =
    { pkgs, ... }:

    {
      programs.steam.extraCompatPackages = [ pkgs.proton-ge-rtsp-bin ];

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
