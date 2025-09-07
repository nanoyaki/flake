{ config, pkgs, ... }:

let
  inherit (config.config'.lab-config) arr;
  domain = config.config'.caddy.genDomain "flood.vpn";
in

{
  config'.vopono.services.qbittorrent = config.services.qbittorrent.webuiPort;

  services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-nox;
    webuiPort = 49574;
    inherit (arr) group;
  };

  services.flood = {
    enable = true;
    port = 24325;
  };

  config'.caddy.reverseProxies.${domain} = {
    vpnOnly = true;
    inherit (config.services.flood) port;
  };

  config'.homepage.categories."Services".services.Flood = {
    icon = "flood.svg";
    href = domain;
    siteMonitor = domain;
    description = "WebUI for torrenting clients";
  };
}
