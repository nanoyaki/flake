{
  lib,
  lib',
  config,
  ...
}:

let
  servarr = [
    "settings"
    "server"
    "port"
  ];

  services = {
    bazarr = [ "listenPort" ];
    # lidarr = servarr;
    prowlarr = servarr;
    radarr = servarr;
    sonarr = servarr;
  };

  deepMerge = lib.foldl lib.recursiveUpdate { };
in

lib.recursiveUpdate
  (deepMerge (
    lib.mapAttrsToList (service: portPath: {
      services.${service}.enable = false;

      services.caddy-easify.reverseProxies."http://${service}.home.local".port =
        lib.getAttrFromPath portPath
          config.services.${service};

      services.homepage-easify.categories."Medien Dienste".services.${lib'.toUppercase service} = rec {
        icon = "${service}.svg";
        href = "http://${service}.home.local";
        siteMonitor = href;
      };
    }) services
  ))
  {
    services.homepage-easify.categories."Medien Dienste".services = {
      Bazarr.description = "Untertitel manager";
      # Lidarr.description = "Musik Sammlung manager";
      Prowlarr.description = "Indexer manager";
      Radarr.description = "Filme manager";
      Sonarr.description = "Digitaler Videorekorder";
    };
  }
