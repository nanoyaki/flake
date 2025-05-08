{ config, ... }:

{
  services.bazarr = {
    enable = true;
    openFirewall = true;
  };

  services.caddy-easify.reverseProxies."http://bazarr.home.local".port =
    config.services.bazarr.listenPort;

  services.homepage-easify.categories."Medien Dienste".services.Bazarr = rec {
    icon = "bazarr.svg";
    href = "http://bazarr.home.local";
    siteMonitor = href;
    description = "Untertitel manager";
  };
}
