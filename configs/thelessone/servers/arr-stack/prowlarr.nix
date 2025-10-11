{ lib, config, ... }:

let
  domain = "https://prowlarr.theless.one";
in

{
  config'.vopono.services.prowlarr = [ config.services.prowlarr.settings.server.port ];

  systemd.services.prowlarr.wantedBy = lib.mkForce [ "vopono.service" ];
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  config'.caddy.vHost.${domain}.proxy = {
    inherit (config.services.prowlarr.settings.server) port;
    inherit (config.config'.vopono) host;
  };

  config'.homepage.categories.Arr.services.Prowlarr = {
    icon = "prowlarr.svg";
    href = domain;
    siteMonitor = domain;
    description = "Indexer manager";
  };
}
