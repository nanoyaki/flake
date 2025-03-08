{
  lib,
  config,
  username,
  ...
}:

let
  cfg = config.services.jellyfin;

  dirCfg = {
    inherit (cfg) user group;
    mode = "0770";
  };
in

{
  services.jellyfin.enable = true;

  users.users.${username}.extraGroups = lib.singleton cfg.group;

  systemd.tmpfiles.settings."10-jellyfin" = {
    ${cfg.dataDir}.d.mode = lib.mkForce "710";
    "${cfg.dataDir}/libraries".d = dirCfg;
    "${cfg.dataDir}/libraries/moviesAndShows".d = dirCfg;
  };
}
