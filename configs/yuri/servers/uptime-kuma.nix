{
  lib,
  inputs',
  pkgs,
  config,
  ...
}:

let
  inherit (inputs') md2img;

  cfg = config.services.caddy;
in

{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "4000";
    };
  };

  config'.caddy.reverseProxies."https://status.nanoyaki.space".port =
    lib.strings.toInt config.services.uptime-kuma.settings.PORT;

  users.users =
    lib.genAttrs
      [
        config.config'.mainUserName
        cfg.user
      ]
      (_: {
        extraGroups = [ "files-nanoyaki-space" ];
      });
  users.groups.files-nanoyaki-space = { };

  services.caddy.virtualHosts."https://files.nanoyaki.space".extraConfig = ''
    root * ${cfg.dataDir}/files.nanoyaki.space
    file_server

    @no_cache path /no-cache/*
    header @no_cache Cache-Control "no-cache"
  '';

  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir}/files.nanoyaki.space 2770 ${cfg.user} files-nanoyaki-space - -"
    "d ${cfg.dataDir}/files.nanoyaki.space/no-cache 2770 ${cfg.user} files-nanoyaki-space - -"
  ];

  systemd.services.uptime-screenshots = {
    wantedBy = [ "multi-user.target" ];
    after = [ "caddy.service" ];

    path = [
      md2img.packages.md2img
      pkgs.imagemagick
    ];

    script = ''
      md2img ${cfg.dataDir}/files.nanoyaki.space/no-cache/full-badges.png

      for i in {0..5}
      do
        magick ${cfg.dataDir}/files.nanoyaki.space/no-cache/full-badges.png \
          -crop "800x$((87 * 4))+126+$((25 + 87 * 4 * i))" \
          -trim -bordercolor none -border 5 -quality 100 \
          "${cfg.dataDir}/files.nanoyaki.space/no-cache/badges.$((i + 1)).webp"
      done
    '';

    startAt = "*:0/10";

    serviceConfig = {
      User = cfg.user;
      Group = "files-nanoyaki-space";

      Type = "oneshot";
      RemainAfterExit = false;
      Restart = "no";
    };
  };
}
