{ config, ... }:
let
  domain = "https://radarr.theless.one";
in

{
  config'.vopono.allowedTCPPorts = [ config.services.radarr.settings.server.port ];

  services.radarr = {
    enable = true;
    inherit (config.arr) group;
  };

  config'.caddy.vHost.${domain}.proxy = { inherit (config.services.radarr.settings.server) port; };

  config'.homepage.categories.Arr.services.Radarr = {
    icon = "radarr.svg";
    href = domain;
    siteMonitor = domain;
    description = "Movie manager";
  };
}
