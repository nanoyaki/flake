{ config, ... }:

{
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  services.caddy-easify.reverseProxies."http://jellyseerr.home.local" = {
    inherit (config.services.jellyseerr) port;
  };

  services.homepage-easify.categories."Medien Dienste".services.Jellyseerr = rec {
    icon = "jellyseerr.svg";
    href = "http://jellyseerr.home.local";
    siteMonitor = href;
    description = "Film und Serien Anfragen";
  };
}
