{ withSystem, ... }:

{
  perSystem =
    { pkgs, ... }:

    {
      packages.solaar = pkgs.symlinkJoin {
        inherit (pkgs.solaar) pname version;
        paths = [ pkgs.solaar ];
        postBuild = ''
          cp $out/share/applications/solaar.desktop solaar.desktop
          rm $out/share/applications/solaar.desktop

          substitute solaar.desktop $out/share/applications/solaar.desktop \
            --replace-fail "solaar" 'solaar -w hide'

          ln -s ${pkgs.solaar.udev} $udev
        '';
        outputs = [
          "out"
          "udev"
        ];
      };
    };

  flake.overlays.solaar =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) solaar;
      }
    );

  flake.nixosModules.shirayuri-desktop =
    { pkgs, ... }:

    {
      environment.systemPackages = [ pkgs.vesktop ];
    };

  flake.homeModules.hana-desktop =
    { pkgs, config, ... }:

    let
      inherit (config.lib.file) mkOutOfStoreSymlink;
    in

    {
      home.packages = [
        pkgs.starrydex
        pkgs.spotify
      ];

      xdg.autostart.entries = [
        "${pkgs.solaar}/share/applications/solaar.desktop"
        "${pkgs.vesktop}/share/applications/vesktop.desktop"
      ];

      catppuccin.thunderbird.profile = "default";
      programs.thunderbird = {
        enable = true;

        profiles.default.isDefault = true;
        profiles.default.withExternalGnupg = true;

        profiles.transacademy = {
          inherit (config.programs.thunderbird.profiles.default) extensions;
          withExternalGnupg = true;
        };
      };

      programs.mpv = {
        enable = true;

        config = {
          osc = "no";
          volume = 40;
        };

        scripts = with pkgs.mpvScripts; [
          sponsorblock
          thumbfast
          modernx
          mpvacious
          mpv-discord
          mpv-subtitle-lines
          mpv-playlistmanager
          mpv-cheatsheet
        ];
      };

      xdg.mimeApps.defaultApplications = {
        "audio/*" = "mpv.desktop";
        "video/*" = "mpv.desktop";
      };

      xdg.autostart.enable = true;

      xdg.userDirs = {
        enable = true;

        desktop = "/home/hana/Desktop";
        download = "/mnt/os-shared/Downloads";
        documents = "/mnt/os-shared/Documents";
        videos = "/mnt/os-shared/Videos";
        pictures = "/mnt/os-shared/Pictures";
        music = "/mnt/os-shared/Music";

        publicShare = null;
        templates = null;
      };

      home.file = {
        Downloads.source = mkOutOfStoreSymlink "/mnt/os-shared/Downloads";
        Documents.source = mkOutOfStoreSymlink "/mnt/os-shared/Documents";
        Videos.source = mkOutOfStoreSymlink "/mnt/os-shared/Videos";
        Pictures.source = mkOutOfStoreSymlink "/mnt/os-shared/Pictures";
        Music.source = mkOutOfStoreSymlink "/mnt/os-shared/Music";

        os-shared.source = mkOutOfStoreSymlink "/mnt/os-shared";
      };
    };
}
