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
    mode = "2770";
  };
in

{
  services.jellyfin.enable = true;

  services.homepage-easify.categories.Media.services.Jellyfin = rec {
    description = "Media suite";
    icon = "jellyfin.svg";
    href = "https://jellyfin.theless.one";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."jellyfin.theless.one".port = 8096;

  users.users.${username}.extraGroups = lib.singleton cfg.group;

  systemd.tmpfiles.settings."10-jellyfin" = {
    "${cfg.dataDir}/libraries".d = dirCfg;
    "${cfg.dataDir}/libraries/moviesAndShows".d = dirCfg;
  };
}
