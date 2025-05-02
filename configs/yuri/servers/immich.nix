{ config, ... }:

{
  services.immich.enable = true;

  services.homepage-easify.categories.Medien.services.Immich = rec {
    description = "Bild Album und Backup Software";
    icon = "immich.svg";
    href = "http://immich.home.local";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."http://immich.home.local" = {
    inherit (config.services.immich) port;
  };
}
