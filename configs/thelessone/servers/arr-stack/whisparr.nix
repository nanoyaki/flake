{ config, ... }:

let
  domain = "https://whisparr.theless.one";
in

{
  config'.vopono.allowedTCPPorts = [ config.services.whisparr.settings.server.port ];

  services.whisparr = {
    enable = true;
    inherit (config.arr) group;
  };

  config'.caddy.vHost.${domain}.proxy.port = config.services.whisparr.settings.server.port;

  config'.homepage.categories.Arr.services.Whisparr = {
    icon = "whisparr.svg";
    href = domain;
    siteMonitor = domain;
    description = "Adult video manager";
  };
}
