{ config, ... }:

let
  domain = "https://sabnzbd.theless.one";
in

{
  config'.vopono.allowedTCPPorts = [ 8080 ];

  services.sabnzbd = {
    enable = true;
    inherit (config.arr) group;
  };

  config'.caddy.vHost.${domain}.proxy.port = 8080;

  config'.homepage.categories.Arr.services.Sabnzbd = {
    icon = "sabnzbd.svg";
    href = domain;
    siteMonitor = domain;
    description = "Usenet binary downloader";
  };
}
