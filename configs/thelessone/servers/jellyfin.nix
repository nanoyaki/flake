{ config, ... }:

let
  cfg = config.services.jellyfin;
in

{
  services.jellyfin.enable = true;

  systemd.tmpfiles.settings."10-jellyfin"."/var/lib/jellyfin/libraries/moviesAndShows".d = {
    inherit (cfg) user group;
    mode = "0770";
  };
}
