{
  lib',
  pkgs,
  ...
}:

{
  imports = [
    ./anime-games.nix
    ./rpgmaker.nix
  ];

  environment.systemPackages =
    (lib'.mapLazyApps (
      with pkgs;
      [
        {
          pkg = dolphin-emu;
          desktopItem = makeDesktopItem {
            desktopName = "Dolphin Emulator";
            name = "dolphin-emulator";
            icon = "dolphin-emu";
            exec = "dolphin-emu";
            terminal = false;
            type = "Application";
            categories = [
              "Game"
              "Emulator"
            ];
            genericName = "Wii/GameCube Emulator";
            comment = "A Wii/GameCube Emulator";
          };
        }
        {
          pkg = lutris;
          desktopItem = makeDesktopItem {
            desktopName = "Lutris";
            name = "lutris";
            startupWMClass = "net.lutris.Lutris";
            comment = "Video Game Preservation Platform";
            categories = [
              "Game"
              "PackageManager"
            ];
            keywords = [
              "gaming"
              "wine"
              "emulator"
            ];
            exec = "lutris %U";
            icon = "net.lutris.Lutris";
            terminal = false;
            type = "Application";
            startupNotify = true;
            mimeTypes = [ "x-scheme-handler/lutris" ];
            extraConfig.X-GNOME-UsesNotifications = "true";
          };
        }
        { pkg = mangohud; }
        {
          pkg = osu-lazer-bin;
          desktopItem = makeDesktopItem {
            desktopName = "osu!";
            name = "osu";
            type = "Application";
            comment = "Rhythm is just a *click* away!";
            icon = "osu";
            exec = "osu! %u";
            terminal = false;
            mimeTypes = [
              "application/x-osu-beatmap-archive"
              "application/x-osu-skin-archive"
              "application/x-osu-beatmap"
              "application/x-osu-storyboard"
              "application/x-osu-replay"
              "x-scheme-handler/osu"
            ];
            categories = [ "Game" ];
            startupWMClass = "osu!";
            startupNotify = true;
            extraConfig.SingleMainWindow = "true";
          };
        }
      ]
    ))
    ++ (with pkgs; [
      prismlauncher
    ]);

  programs.gamemode = {
    enable = true;
    enableRenice = true;

    settings = {
      general.renice = 10;
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
}
