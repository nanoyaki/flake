{
  self,
  pkgs,
  config,
  ...
}:

let
  cfg = config.services.transmission;
in

{
  imports = [ self.nixosModules.vopono ];

  sec."vopono/wireguard.conf".owner = cfg.user;

  services.vopono = {
    enable = true;

    configFile = config.sec."vopono/wireguard.conf".path;
    protocol = "Wireguard";

    services.transmission = cfg.settings.rpc-port;
  };

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    webHome = pkgs.flood-for-transmission;

    group = "arr-stack";
    downloadDirPermissions = "770";
    settings = {
      download-dir = "/home/arr-stack/downloads/transmission/complete";
      incomplete-dir = "/home/arr-stack/downloads/transmission/incomplete";
      incomplete-dir-enabled = true;
      rpc-host-whitelist = "*";
      rpc-host-whitelist-enabled = true;
      ratio-limit = 0;
      ratio-limit-enabled = true;
    };
  };

  services.caddy-easify.reverseProxies."http://transmission.theless.one" = {
    port = cfg.settings.rpc-port;
    userEnvVar = "shared";
  };

  services.homepage-easify.categories.Dienste.services.Transmission = rec {
    icon = "transmission.svg";
    href = "http://transmission.theless.one";
    siteMonitor = href;
    description = "Torrent client";
  };
}
