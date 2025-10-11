{ config, ... }:

let
  domain = "https://sonarr.theless.one";
in

{
  config'.vopono.allowedTCPPorts = [ config.services.sonarr.settings.server.port ];

  services.sonarr = {
    enable = true;
    inherit (config.arr) group;
  };

  config'.caddy.vHost.${domain}.proxy = { inherit (config.services.sonarr.settings.server) port; };

  config'.homepage.categories.Arr.services.Sonarr = {
    icon = "sonarr.svg";
    href = domain;
    siteMonitor = domain;
    description = "Series manager";
  };
}
