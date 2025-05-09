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
in

{
  imports = lib.map (service: ./. + "/${service}.nix") [
    "radarr"
    "bazarr"
    "jellyseerr"
    "prowlarr"
    "sonarr"
  ];

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

  users.groups.arr-stack = { };
  users.users.${username}.extraGroups = lib.singleton "arr-stack";
}
