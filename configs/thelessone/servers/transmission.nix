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
    openFirewall = true;
    package = pkgs.transmission_4;
    webHome = pkgs.flood-for-transmission;

    extraFlags = [ "-a *.*.*.*" ];

    group = "arr-stack";
    downloadDirPermissions = "770";
    settings = {
      download-dir = "/home/arr-stack/downloads/transmission/complete";
      incomplete-dir = "/home/arr-stack/downloads/transmission/incomplete";
      incomplete-dir-enabled = true;
      rpc-whitelist = "*.*.*.*";
      rpc-host-whitelist = "*";
      rpc-host-whitelist-enabled = true;
      ratio-limit = 0;
      ratio-limit-enabled = true;
    };
  };

  services.caddy-easify.reverseProxies."transmission.theless.one" = {
    port = cfg.settings.rpc-port;
    host = "10.200.1.1";
    userEnvVar = "shared";
  };

  services.homepage-easify.categories.Services.services.Transmission = rec {
    icon = "transmission.svg";
    href = "https://transmission.theless.one";
    siteMonitor = href;
    description = "Torrent client";
  };
}
