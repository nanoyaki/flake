{ config, pkgs, ... }:

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
    theming.enable = true;
    flatpak.enable = true;
    ssh.defaultId = "${config.hm.home.homeDirectory}/.ssh/id_nadesiko";
    fcitx5.enable = true;
  };

  virtualisation.waydroid.enable = true;

  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreiarzaifqcdw4mugzplv3t6qxp7kydjglgsy65dz3g4afyjlviemqy@png";
    hash = "sha256-VyyCflVNdt5k90vXkHxlQ9TvNjxk8NmZMxb45UMpCgA=";
  };
}
