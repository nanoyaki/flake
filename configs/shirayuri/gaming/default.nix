{
  lib',
  pkgs,
  ...
}:

{
  imports = [
    ./anime-games.nix
    ./rpgmaker.nix
    ./emulation.nix
  ];

  environment.systemPackages =
    (lib'.mapLazyApps (
      with pkgs;
      [
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
        {
          pkg = r2modman;
          desktopItem = makeDesktopItem {
            name = "r2modman";
            exec = "r2modman %U";
            icon = fetchurl {
              url = "https://raw.githubusercontent.com/ebkr/r2modmanPlus/73d76d1eb5b1d9bab12b32a64b9c0763e13bf2fe/public/icon.png";
              hash = "sha256-UdEzW2BBBOdo6Q5AP1P/jpSBpeYKhgumB9XJ5HFn/pQ=";
            };
            desktopName = "r2modman";
            comment = "Unofficial Thunderstore mod manager";
            categories = [ "Game" ];
            mimeTypes = [ "x-scheme-handler/ror2mm" ];
            keywords = [
              "launcher"
              "mod manager"
              "thunderstore"
            ];
          };
        }
        {
          pkg = bs-manager;
          desktopItem = makeDesktopItem {
            desktopName = "BSManager";
            name = "BSManager";
            exec = "bs-manager";
            terminal = false;
            type = "Application";
            icon = fetchurl {
              url = "https://raw.githubusercontent.com/Zagrios/bs-manager/d9b4259b9723e0e885f69ab95ddfbb762876c3b3/resources/readme/PNG/icon.png";
              hash = "sha256-Gf1X0fPdMyYVk/r34ndub1iNS87B4f18sGq4PrBcWOg=";
            };
            mimeTypes = [
              "x-scheme-handler/bsmanager"
              "x-scheme-handler/beatsaver"
              "x-scheme-handler/bsplaylist"
              "x-scheme-handler/modelsaber"
              "x-scheme-handler/web+bsmap"
            ];
            categories = [
              "Utility"
              "Game"
            ];
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
