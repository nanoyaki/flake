{
  lib,
  config,
  ...
}:

let
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

  config'.caddy.vHost."https://status.nanoyaki.space".proxy.port =
    lib.strings.toInt config.services.uptime-kuma.settings.PORT;

  users.users =
    lib.genAttrs
      [
        config.nanoSystem.mainUserName
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
}
