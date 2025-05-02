{ config, ... }:

{
  services.immich = {
    enable = true;
    port = 2283;
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };

  services.homepage-easify.categories.Media.services.Immich = rec {
    description = "Self-hosted photo management solution";
    icon = "immich.svg";
    href = "https://immich.theless.one";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."immich.theless.one" = {
    inherit (config.services.immich) port;
    serverAliases = [ "immich.nanoyaki.space" ];
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
}
