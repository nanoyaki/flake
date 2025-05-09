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

          services.caddy-easify.reverseProxies."${service}.theless.one".port =
            lib.getAttrFromPath servicePortMap.${service}
              config.services.${service};

          services.homepage-easify.categories."Arr Stack".services.${lib'.toUppercase service} = rec {
            icon = "${service}.svg";
            href = "https://${service}.theless.one";
            siteMonitor = href;
          };
        }) (lib.attrNames servicePortMap)
      ))
      {
        services.homepage-easify.categories."Arr Stack".services = {
          Bazarr.description = "Subtitle manager";
          Lidarr.description = "Music manager";
          Prowlarr.description = "Usenet indexer manager";
          Radarr.description = "Movie manager";
          Sonarr.description = "Show manager";
          Jellyseerr.description = "Movie requests";
        };

        systemd.tmpfiles.settings."10-libraries" = {
          "/home/arr-stack".d = dirCfg;

          "/home/arr-stack/libraries".d = dirCfg;
          "/home/arr-stack/libraries/movies".d = dirCfg;
          "/home/arr-stack/libraries/shows".d = dirCfg;

          "/home/arr-stack/anisync".d = dirCfg;

          "/home/arr-stack/libraries/anime".d = dirCfg;
          "/home/arr-stack/libraries/anime/movies".d = dirCfg;
          "/home/arr-stack/libraries/anime/shows".d = dirCfg;

          "/home/arr-stack/downloads".d = dirCfg;
          "/home/arr-stack/downloads/transmission".d = dirCfg // {
            inherit (config.services.transmission) user;
          };
          "/home/arr-stack/downloads/transmission/complete".d = dirCfg // {
            inherit (config.services.transmission) user;
          };
          "/home/arr-stack/downloads/transmission/incomplete".d = dirCfg // {
            inherit (config.services.transmission) user;
          };

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
