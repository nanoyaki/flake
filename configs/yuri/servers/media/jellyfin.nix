{
  services.jellyfin.enable = true;

  services.homepage-easify.categories.Medien.services.Jellyfin = rec {
    description = "Filme und Serien Archiv";
    icon = "jellyfin.svg";
    href = "http://jellyfin.home.local";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."http://jellyfin.home.local".port = 8096;
}
