{
  lib,
  lib',
  config,
  username,
  ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.services.arr-stack.enabled;

  servicePortMap = rec {
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

  dirCfg = {
    inherit (config.services.jellyfin) user;
    group = "arr-stack";
    mode = "2770";
  };

  deepMerge = lib.foldl lib.recursiveUpdate { };
in

{
  options.services.arr-stack.enabled = mkOption {
    type = types.listOf (types.enum (lib.attrNames servicePortMap));
    default = lib.attrNames servicePortMap;
  };

  config =
    lib.recursiveUpdate
      (deepMerge (
        lib.map (service: {
          services.${service} = {
            enable = lib.elem service cfg;
            openFirewall = true;
          };

          services.caddy-easify.reverseProxies."http://${service}.home.local".port =
            lib.getAttrFromPath servicePortMap.${service}
              config.services.${service};

          services.homepage-easify.categories."Medien Dienste".services.${lib'.toUppercase service} = rec {
            icon = "${service}.svg";
            href = "http://${service}.home.local";
            siteMonitor = href;
          };
        }) (lib.attrNames servicePortMap)
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

        systemd.tmpfiles.settings."10-libraries" = {
          "/home/arr-stack".d = dirCfg;

          "/home/arr-stack/libraries/movies".d = dirCfg;
          "/home/arr-stack/libraries/shows".d = dirCfg;

          "/home/arr-stack/anisync".d = dirCfg;

          "/home/arr-stack/libraries/anime/movies".d = dirCfg;
          "/home/arr-stack/libraries/anime/shows".d = dirCfg;

          "/home/arr-stack/downloads/complete".d = dirCfg // {
            inherit (config.services.sabnzbd) user;
          };
          "/home/arr-stack/downloads/incomplete".d = dirCfg // {
            inherit (config.services.sabnzbd) user;
          };
        };

        services.radarr.group = "arr-stack";
        services.sonarr.group = "arr-stack";

        users.groups.arr-stack = { };
        users.users.${username}.extraGroups = lib.singleton "arr-stack";
      };
}
