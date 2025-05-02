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

  dirCfg = {
    inherit (config.services.jellyfin) user;
    group = "arr-stack";
    mode = "2770";
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

          services.caddy-easify.reverseProxies."${service}.theless.one".port =
            lib.getAttrFromPath portPath
              config.services.${service};

          services.homepage-easify.categories."Arr Stack".services.${lib'.toUppercase service} = rec {
            icon = "${service}.svg";
            href = "https://${service}.theless.one";
            siteMonitor = href;
          };
        }) services
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
        };

        users.users =
          (lib.mapAttrs'
            (
              service: _:
              lib.nameValuePair config.services.${service}.user { extraGroups = lib.singleton "arr-stack"; }
            )
            (
              lib.filterAttrs (
                service: _: config.services.${service} ? user && config.services.${service}.enable
              ) services
            )
          )
          // {
            ${username}.extraGroups = lib.singleton "arr-stack";
          };
      };
}
