{ inputs, pkgs, ... }:

let
  inherit (inputs) aagl;
in

{
  imports = [ aagl.nixosModules.default ];
  nix.settings = aagl.nixConfig; # Cachix

  programs = with pkgs; {
    anime-game-launcher = {
      enable = true;
      package = lazy-app.override {
        pkg = anime-game-launcher;
        desktopItem = makeDesktopItem {
          name = "anime-game-launcher";
          desktopName = "Anime Game Launcher";
          categories = [ "Game" ];
          exec = "anime-game-launcher";
          genericName = "An Anime Game Launcher";
          icon = fetchurl {
            url = "https://raw.githubusercontent.com/an-anime-team/an-anime-game-launcher/0ea0ec6640da846dfc4aedf4458012f9bb874b41/assets/images/icon.png";
            hash = "sha256-4ue/zzwJdzBCNyuqFYEZIz1cIVcyHwhyX/jAwxPu93Q=";
          };
          startupNotify = true;
          startupWMClass = "moe.launcher.an-anime-game-launcher";
          type = "Application";
        };
      };
    };
    honkers-railway-launcher = {
      enable = true;
      package = lazy-app.override {
        pkg = honkers-railway-launcher;
        desktopItem = makeDesktopItem {
          name = "honkers-railway-launcher";
          desktopName = "The Honkers Railway Launcher";
          categories = [ "Game" ];
          exec = "honkers-railway-launcher";
          genericName = "The Honkers Railway Launcher";
          icon = fetchurl {
            url = "https://raw.githubusercontent.com/an-anime-team/the-honkers-railway-launcher/9f3bd39baa41184377126ae01d0611ce615bc6a5/assets/images/icon.png";
            hash = "sha256-F5SnPEVaU2R/JxN3fsqdD+sdqCn7k7WzdM2Y/8J7XB4=";
          };
          startupNotify = true;
          startupWMClass = "moe.launcher.the-honkers-railway-launcher";
          type = "Application";
        };
      };
    };
    sleepy-launcher = {
      enable = true;
      package = lazy-app.override {
        pkg = sleepy-launcher;
        desktopItem = makeDesktopItem {
          desktopName = "Sleepy Launcher";
          name = "sleepy-launcher";
          categories = [ "Game" ];
          exec = "sleepy-launcher";
          genericName = "Sleepy Launcher";
          icon = fetchurl {
            url = "https://raw.githubusercontent.com/an-anime-team/sleepy-launcher/f91bb11626439c85a07a3f5a84ec8410b0721f40/assets/images/icon.png";
            hash = "sha256-e5WTalA95+oFzj4n+2PGxO7swEjaSCUDnuqli3LraBo=";
          };
          startupNotify = true;
          startupWMClass = "moe.launcher.sleepy-launcher";
          type = "Application";
        };
      };
    };
  };
}
