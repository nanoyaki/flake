{ config, ... }:

let
  domain = "https://immich.theless.one";
in

{
  services.immich = {
    enable = true;
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };

  users.users.${config.services.immich.user}.extraGroups = [
    "video"
    "render"
  ];

  services.immich-public-proxy = {
    enable = true;
    immichUrl = "http://localhost:2283";
    port = 19220;
    settings.allowDownloadAll = 1;
  };

  config'.caddy.vHost."images.theless.one".proxy = {
    inherit (config.services.immich-public-proxy) port;
  };

  config'.caddy.vHost.${domain}.proxy = { inherit (config.services.immich) port; };

  config'.homepage.categories.Media.services.Immich = {
    icon = "immich.svg";
    href = domain;
    siteMonitor = domain;
    description = "Image backup service";
  };

  sops.secrets."restic/immich" = { };

  config'.restic.backups.immich = {
    repository = "/mnt/raid/backups/immich";
    passwordFile = config.sops.secrets."restic/immich".path;

    basePath = "/var/lib/immich";
    exclude = [ "thumbs" ];

    timerConfig.OnCalendar = "daily";
  };
}
