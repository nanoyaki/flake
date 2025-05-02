{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.services.arr-stack.enabled;

  services = rec {
    bazarr = [ "listenPort" ];
    jellyseerr = [ "port" ];
    lidarr = [
      "settings"
      "server"
      "port"
    ];
    prowlarr = lidarr;
    radarr = lidarr;
    sonarr = lidarr;
  };

  deepMerge = lib.foldl lib.recursiveUpdate { };
in

{
  options.services.arr-stack.enabled = mkOption {
    type = types.listOf (types.enum (lib.attrNames services));
    default = lib.attrNames services;
  };

  config =
    lib.recursiveUpdate
      (deepMerge (
        lib.mapAttrsToList (service: portPath: {
          services.${service}.enable = lib.elem service cfg;

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
          Lidarr.description = "Musik Sammlung manager";
          Prowlarr.description = "Indexer manager";
          Radarr.description = "Filme manager";
          Sonarr.description = "Digitaler Videorekorder";
          Jellyseerr.description = "Film-Anfragen";
        };
      };
}
