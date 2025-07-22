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
          desktopName = "An Anime Game Launcher";
          categories = [ "Game" ];
          exec = "anime-game-launcher";
          genericName = "An Anime Game Launcher";
          icon = "moe.launcher.an-anime-game-launcher";
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
          icon = "moe.launcher.the-honkers-railway-launcher";
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
          icon = "moe.launcher.sleepy-launcher";
          startupNotify = true;
          startupWMClass = "moe.launcher.sleepy-launcher";
          type = "Application";
        };
      };
    };
  };
}
