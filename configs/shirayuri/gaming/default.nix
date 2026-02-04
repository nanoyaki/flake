{ pkgs, ... }:

{
  imports = [
    ./anime-games.nix
    ./rpgmaker.nix
    ./emulation.nix
  ];

  environment.systemPackages = with pkgs; [
    mangohud
    r2modman
    bs-manager
    lutris
    prismlauncher
    osu-lazer-bin
  ];

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
