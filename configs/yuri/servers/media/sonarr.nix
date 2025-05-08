{ config, ... }:

{
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "arr-stack";
  };

  services.caddy-easify.reverseProxies."http://sonarr.home.local" = {
    inherit (config.services.sonarr.settings.server) port;
  };

  services.homepage-easify.categories."Medien Dienste".services.Sonarr = rec {
    icon = "sonarr.svg";
    href = "http://sonarr.home.local";
    siteMonitor = href;
    description = "Serien manager";
  };
}
