{ config, ... }:

{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.caddy-easify.reverseProxies."http://prowlarr.home.local" = {
    inherit (config.services.prowlarr.settings.server) port;
  };

  services.homepage-easify.categories."Medien Dienste".services.Prowlarr = rec {
    icon = "prowlarr.svg";
    href = "http://prowlarr.home.local";
    siteMonitor = href;
    description = "Indexer manager";
  };
}
