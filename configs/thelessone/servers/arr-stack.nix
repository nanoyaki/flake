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

  rule = path: "d ${path} 2770 ${config.services.jellyfin.user} arr-stack";

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

        systemd.tmpfiles.rules = [
          (rule "/home/arr-stack")

          (rule "/home/arr-stack/libraries")
          (rule "/home/arr-stack/libraries/movies")
          (rule "/home/arr-stack/libraries/shows")

          (rule "/home/arr-stack/anisync")

          (rule "/home/arr-stack/libraries/anime")
          (rule "/home/arr-stack/libraries/anime/movies")
          (rule "/home/arr-stack/libraries/anime/shows")

          "d /home/arr-stack/downloads/complete 2770 ${config.services.sabnzbd.user} arr-stack"
          "d /home/arr-stack/downloads/incomplete 2770 ${config.services.sabnzbd.user} arr-stack"
        ];

        services.radarr.group = "arr-stack";
        services.sonarr.group = "arr-stack";

        users.groups.arr-stack = { };
        users.users.${username}.extraGroups = lib.singleton "arr-stack";
      };
}
