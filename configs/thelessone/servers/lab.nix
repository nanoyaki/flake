# This code sucks, i'll change it whenever i feel like it
{
  config' = {
    lab-config.enable = true;
    lab-config.arr.home = "/mnt/raid/arr-stack";

    bazarr.enable = true;
    bazarr.subdomain = "bazarr.vpn";
    flaresolverr.enable = true;
    jellyseerr.enable = true;
    jellyseerr.subdomain = "jellyseerr.vpn";
    lidarr.enable = true;
    lidarr.subdomain = "lidarr.vpn";
    prowlarr.enable = true;
    prowlarr.subdomain = "prowlarr.vpn";
    radarr.enable = true;
    radarr.subdomain = "radarr.vpn";
    sabnzbd.enable = true;
    sabnzbd.subdomain = "sabnzbd.vpn";
    sonarr.enable = true;
    sonarr.subdomain = "sonarr.vpn";
    transmission.enable = false;
    transmission.subdomain = "transmission.vpn";
    whisparr.enable = true;
    whisparr.subdomain = "whisparr.vpn";
    whisparr.homepage.enable = true;
    vopono.enable = true;
  };
}
