{ pkgs, config, ... }:

let
  domain = "https://jellyfin.theless.one";
  vpnDomain = "https://jellyfin.vpn.theless.one";
in

{
  services.jellyfin = {
    enable = true;
    package = pkgs.jellyfin.override {
      jellyfin-web = pkgs.jellyfin-web-with-plugins;
    };
    inherit (config.arr) group;
  };
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "nvidia";

  config'.caddy.vHost.${domain}.proxy.port = 8096;
  config'.caddy.vHost.${vpnDomain} = {
    vpnOnly = true;
    proxy.port = 8096;
  };

  config'.homepage.categories.Media.services.Jellyfin = {
    icon = "jellyfin.svg";
    href = domain;
    siteMonitor = domain;
    description = "Server for archived media";
  };

  users.users.${config.services.jellyfin.user}.extraGroups = [
    "video"
    "render"
  ];

  systemd.services.jellyfin.restartTriggers = [ config.hardware.nvidia.package ];

  sops.secrets."restic/jellyfin" = { };

  config'.restic.backups.jellyfin = {
    repository = "/mnt/raid/backups/jellyfin";
    passwordFile = config.sops.secrets."restic/jellyfin".path;

    basePath = "/var/lib/jellyfin";
    exclude = [
      "metadata/library"
      "data/subtitles"
    ];

    timerConfig.OnCalendar = "daily";
  };
}
