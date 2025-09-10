{ config, ... }:

let
  domain = config.config'.caddy.genDomain "audiobookshelf";
in

{
  services.audiobookshelf = {
    enable = true;
    port = 46551;
  };

  fileSystems."/var/lib/audiobookshelf" = {
    device = "/mnt/raid/audiobookshelf";
    depends = [ "/mnt/raid" ];
    options = [ "bind" ];
  };

  systemd.services.audiobookshelf.unitConfig.RequiresMountsFor = "/mnt/raid/audiobookshelf";

  config'.caddy.reverseProxies.${domain} = {
    useMtls = true;
    inherit (config.services.audiobookshelf) port;
  };

  config'.homepage.categories.Media.services.Audiobookshelf = {
    icon = "audiobookshelf.svg";
    href = domain;
    siteMonitor = domain;
    description = "Audiobook archive";
  };
}
