{
  lib,
  pkgs,
  ...
}:

{
  config' = {
    mpv.enable = true;

    yubikey = {
      enable = true;
      yuri.enable = true;
    };
    steam.enable = true;
    wivrn.enable = true;
    theming.enable = true;
  };

  services.syncthing'.enable = true;

  console.keyMap = lib.mkForce "sv-latin1";

  hm.home.packages = with pkgs; [
    prismlauncher
    xivlauncher
    nur.repos.ataraxiasjel.waydroid-script
  ];

  programs.thunderbird.enable = true;

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

  virtualisation.waydroid.enable = true;

  environment.systemPackages = with pkgs; [
    bs-manager
    wayland-bongocat
    nixd
    nixfmt
    vesktop
    melonDS
  ];

  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreiarzaifqcdw4mugzplv3t6qxp7kydjglgsy65dz3g4afyjlviemqy@png";
    hash = "sha256-VyyCflVNdt5k90vXkHxlQ9TvNjxk8NmZMxb45UMpCgA=";
  };
}
