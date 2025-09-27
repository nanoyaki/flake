{
  config,
  pkgs,
  ...
}:

{
  config' = {
    localization = {
      timezone = "Europe/Stockholm";
      language = "en_GB";
      locale = "sv_SE.UTF-8";
    };
    # keyboard.layout = "se";

    audio.latency = 256;
    mpv.enable = true;

    yubikey = {
      enable = true;
      yuri.enable = true;
    };
    steam.enable = true;
    wivrn.enable = true;
    theming.enable = true;
    flatpak.enable = true;
    ssh.defaultId = "${config.hm.home.homeDirectory}/.ssh/id_nadesiko";
    fcitx5.enable = true;
  };

  hm.home.packages = with pkgs; [
    prismlauncher
    xivlauncher
    nur.repos.ataraxiasjel.waydroid-script
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

  virtualisation.waydroid.enable = true;

  environment.systemPackages = with pkgs; [
    bs-manager
  ];

  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreiarzaifqcdw4mugzplv3t6qxp7kydjglgsy65dz3g4afyjlviemqy@png";
    hash = "sha256-VyyCflVNdt5k90vXkHxlQ9TvNjxk8NmZMxb45UMpCgA=";
  };
}
