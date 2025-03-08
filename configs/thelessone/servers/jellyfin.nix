{ config, ... }:

let
  cfg = config.services.jellyfin;

  dirCfg = {
    inherit (cfg) user group;
    mode = "0770";
  };
in

{
  services.jellyfin.enable = true;

  systemd.tmpfiles.settings."10-jellyfin" = {
    "/var/lib/jellyfin/libraries".d = dirCfg;
    "/var/lib/jellyfin/libraries/moviesAndShows".d = dirCfg;
  };
}
