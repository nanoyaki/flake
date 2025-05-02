{
  lib,
  config,
  ...
}:

let
  cfg = config.services.jellyfin;
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

  users.users.${cfg.user}.extraGroups = lib.singleton "arr-stack";
}
