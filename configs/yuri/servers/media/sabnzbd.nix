{
  services.sabnzbd = {
    enable = true;
    group = "arr-stack";
  };

  services.homepage-easify.categories.Dienste.services.Sabnzbd = rec {
    description = "Usenet client";
    icon = "sabnzbd.svg";
    href = "http://sabnzbd.home.local";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."http://sabnzbd.home.local".port = 8080;
}
