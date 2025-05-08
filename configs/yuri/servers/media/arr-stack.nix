{
  lib,
  config,
  username,
  ...
}:

let
  dirCfg = {
    inherit (config.services.jellyfin) user;
    group = "arr-stack";
    mode = "2770";
  };

  arrServices = [
    "radarr"
    "bazarr"
    "jellyseerr"
    "prowlarr"
    "sonarr"
    "lidarr"
  ];
in

{
  imports = lib.map (service: ./. + "/${service}.nix") arrServices;

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

  users.groups.arr-stack = { };
  users.users.${username}.extraGroups = lib.singleton "arr-stack";
}
