{ config, ... }:

{
  systemd.services.jellyfin.restartTriggers = [ config.hardware.nvidia.package ];

  config'.jellyfin.enable = true;

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

  config'.caddy.vHost."jellyfin.vpn.theless.one" = {
    vpnOnly = true;
    proxy.port = 8096;
  };
}
