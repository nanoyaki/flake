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
          "/home/arr-stack/libraries/anime/movies".d = dirCfg;
          "/home/arr-stack/libraries/anime/shows".d = dirCfg;
        };

        users.groups.arr-stack = { };

        users.users =
          (lib.listToAttrs (
            lib.map (
              service:
              lib.nameValuePair config.services.${service}.user { extraGroups = lib.singleton "arr-stack"; }
            ) (lib.filter (service: config.services.${service} ? user) cfg)
          ))
          // {
            ${username}.extraGroups = lib.singleton "arr-stack";
          };
      };
}
