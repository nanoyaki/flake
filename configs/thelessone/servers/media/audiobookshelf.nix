{ config, ... }:

let
  domain = "https://audiobookshelf.theless.one";
in

{
  services.audiobookshelf = {
    enable = true;
    port = 46551;
  };

  sops.secrets."restic/audiobookshelf" = { };

  config'.restic.backups.audiobookshelf = {
    repository = "/mnt/raid/backups/audiobookshelf";
    passwordFile = config.sops.secrets."restic/audiobookshelf".path;

    basePath = "/mnt/raid";
    paths = [ "audiobookshelf" ];

    timerConfig.OnCalendar = "daily";
  };

  fileSystems."/var/lib/audiobookshelf" = {
    device = "/mnt/raid/audiobookshelf";
    depends = [ "/mnt/raid" ];
    options = [ "bind" ];
  };

  systemd.services.audiobookshelf.unitConfig.RequiresMountsFor = "/mnt/raid/audiobookshelf";

  config'.caddy.vHost.${domain} = {
    proxy = { inherit (config.services.audiobookshelf) port; };
    useMtls = true;
  };

  config'.caddy.vHost."https://audiobookshelf.vpn.theless.one" = {
    proxy = { inherit (config.services.audiobookshelf) port; };
    vpnOnly = true;
  };

  config'.homepage.categories.Media.services.Audiobookshelf = {
    icon = "audiobookshelf.svg";
    href = domain;
    siteMonitor = domain;
    description = "Audiobook archive";
  };
}
