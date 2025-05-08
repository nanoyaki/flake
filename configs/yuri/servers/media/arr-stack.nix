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
    bazarr = {
      portPath = [ "listenPort" ];
      description = "Untertitel manager";
    };
    jellyseerr = {
      portPath = [ "port" ];
      description = "Film-Anfragen";
    };
    lidarr = {
      portPath = [
        "settings"
        "server"
        "port"
      ];
      description = "Musik Sammlung manager";
    };
    prowlarr = {
      inherit (lidarr) portPath;
      description = "Indexer manager";
    };
    radarr = {
      inherit (lidarr) portPath;
      description = "Filme manager";
    };
    sonarr = {
      inherit (lidarr) portPath;
      description = "Serien manager";
    };
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
            enable = true;
            openFirewall = true;
          };

          services.caddy-easify.reverseProxies."http://${service}.home.local".port =
            lib.getAttrFromPath servicePortMap.${service}.portPath
              config.services.${service};

          services.homepage-easify.categories."Medien Dienste".services.${lib'.toUppercase service} = rec {
            icon = "${service}.svg";
            href = "http://${service}.home.local";
            siteMonitor = href;
            inherit (servicePortMap.${service}) description;
          };
        }) cfg
      ))
      {
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
