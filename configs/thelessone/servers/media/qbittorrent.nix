{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.config'.lab-config) arr;
  domain = config.config'.caddy.genDomain "flood.vpn";
  cfg = config.services.qbittorrent;
in

{
  sops.secrets.qbittorrent-password = { };

  sops.templates."qBittorrent.conf" = {
    content = ''
      [LegalNotice]
      Accepted=true

      [BitTorrent]
      Session\GlobalMaxRatio=2

      [Preferences]
      WebUI\Port=49574
      Downloads\SavePath=${config.config'.transmission.completeDirectory}
      Downloads\TempPath=${config.config'.transmission.incompleteDirectory}
      Downloads\GlobalDlLimit=15000
      Connection\GlobalUPLimit=2500
    '';
    restartUnits = [ "qbittorrent.service" ];
    mode = "0644";
    owner = cfg.user;
    inherit (cfg) group;
  };

  systemd.services.qbittorrent.serviceConfig.ExecStartPre =
    "${lib.getExe' pkgs.coreutils-full "cp"} -f ${
      config.sops.templates."qBittorrent.conf".path
    } ${cfg.profileDir}/qBittorrent/config/qBittorrent.conf";

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
