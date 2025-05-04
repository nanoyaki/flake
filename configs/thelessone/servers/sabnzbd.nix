{
  services.sabnzbd = {
    enable = true;
    group = "arr-stack";
  };

  services.homepage-easify.categories.Services.services.Sabnzbd = rec {
    description = "Usenet client";
    icon = "sabnzbd.svg";
    href = "https://sabnzbd.theless.one";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."sabnzbd.theless.one".port = 8080;
}
