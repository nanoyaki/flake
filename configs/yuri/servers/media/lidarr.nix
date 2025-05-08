{ config, ... }:

{
  services.lidarr = {
    enable = true;
    openFirewall = true;
  };

  services.caddy-easify.reverseProxies."http://lidarr.home.local" = {
    inherit (config.services.lidarr.settings.server) port;
  };

  services.homepage-easify.categories."Medien Dienste".services.Lidarr = rec {
    icon = "lidarr.svg";
    href = "http://lidarr.home.local";
    siteMonitor = href;
    description = "Musik manager";
  };
}
