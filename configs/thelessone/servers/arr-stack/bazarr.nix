{ config, ... }:

let
  inherit (config) arr;

  domain = "https://bazarr.theless.one";
in

{
  services.bazarr = {
    enable = true;
    inherit (arr) group;
  };

  config'.caddy.vHost.${domain}.proxy.port = config.services.bazarr.listenPort;

  config'.homepage.categories.Arr.services.Bazarr = {
    icon = "bazarr.svg";
    href = domain;
    siteMonitor = domain;
    description = "Subtitle manager";
  };
}
