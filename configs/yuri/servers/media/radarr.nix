{ config, ... }:

{
  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "arr-stack";
  };

  services.caddy-easify.reverseProxies."http://radarr.home.local" = {
    inherit (config.services.radarr.settings.server) port;
  };

  services.homepage-easify.categories."Medien Dienste".services.Radarr = rec {
    icon = "radarr.svg";
    href = "http://radarr.home.local";
    siteMonitor = href;
    description = "Filme manager";
  };
}
