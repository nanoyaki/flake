{ config, ... }:

let
  inherit (config.config'.lab-config) arr;
  domain = config.config'.caddy.genDomain "flood";
  cfg = config.services.deluge;
in

{
  sops.secrets = {
    "deluge/localclient" = { };
    "deluge/nanoyaki" = { };
    "deluge/sonarr" = { };
    "deluge/radarr" = { };
    "deluge/prowlarr" = { };
  };

  sops.templates.deluge-auth = {
    content = ''
      localclient:${config.sops.placeholder."deluge/localclient"}:10
      nanoyaki:${config.sops.placeholder."deluge/nanoyaki"}:10
      sonarr:${config.sops.placeholder."deluge/sonarr"}:5
      radarr:${config.sops.placeholder."deluge/radarr"}:5
      prowlarr:${config.sops.placeholder."deluge/prowlarr"}:5
    '';
    restartUnits = [ "deluged.service" ];
    mode = "640";
    owner = cfg.user;
    inherit (cfg) group;
  };

  config'.vopono.services.deluged = cfg.config.daemon_port;

  services.deluge = {
    declarative = true;
    enable = true;
    inherit (arr) group;

    openFirewall = true;

    config = {
      max_download_speed = 15000.0;
      max_upload_speed = 2500.0;
      share_ratio_limit = 2.0;
      stop_seed_at_ratio = 2.0;
      allow_remote = true;
      daemon_port = 58846;
      listen_ports = [
        6881
        6891
      ];
      download_location = "/mnt/raid/arr-stack/downloads/transmission/incomplete";
      move_completed = true;
      move_completed_path = "/mnt/raid/arr-stack/downloads/transmission/complete";
    };

    authFile = config.sops.templates.deluge-auth.path;
  };

  config'.vopono.allowedTCPPorts = [ config.services.flood.port ];

  services.flood = {
    enable = true;
    host = "0.0.0.0";
    port = 24325;
  };

  config'.caddy.reverseProxies.${domain} = {
    useMtls = true;
    inherit (config.services.flood) port;
  };

  config'.homepage.categories."Services".services.Flood = {
    icon = "flood.svg";
    href = domain;
    siteMonitor = domain;
    description = "WebUI for torrenting clients";
  };
}
