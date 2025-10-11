{ config, ... }:

let
  domain = "https://lidarr.theless.one";
in

{
  config'.vopono.allowedTCPPorts = [ config.services.lidarr.settings.server.port ];

  services.lidarr = {
    enable = true;
    inherit (config.arr) group;
  };

  config'.caddy.vHost.${domain}.proxy = { inherit (config.services.lidarr.settings.server) port; };

  config'.homepage.categories.Arr.services.Lidarr = {
    icon = "lidarr.svg";
    href = domain;
    siteMonitor = domain;
    description = "Music manager";
  };
}
