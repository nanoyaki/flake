{
  pkgs,
  inputs',
  ...
}:

let
  mapLazyApps = pkgs: map inputs'.lazy-apps.packages.lazy-app.override pkgs;
in

{
  imports = [
    ./anime-games.nix
    ./rpgmaker.nix
    ./emulation.nix
  ];

  environment.systemPackages =
    (mapLazyApps (
      with pkgs;
      [
        { pkg = mangohud; }
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
      lutris
      prismlauncher
      osu-lazer-bin
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
