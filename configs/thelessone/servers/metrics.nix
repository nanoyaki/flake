{ lib, config, ... }:

let
  inherit (lib.lists) map;
in

{
  sec = {
    "apiKeys/sabnzbd" = { };
    "apiKeys/sonarr" = { };
    "apiKeys/radarr" = { };
    "apiKeys/prowlarr" = { };
    "apiKeys/lidarr" = { };
    "apiKeys/bazarr" = { };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 2342;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.vpn.theless.one";
      };

      analytics.reporting_enabled = false;
    };
  };

  services.prometheus = {
    enable = true;
    port = 9092;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
      };

      smartctl = {
        enable = true;
        devices = [
          "/dev/sda"
          "/dev/sdb"
          "/dev/nvme0n1"
        ];
        port = 9633;
      };

      sabnzbd = {
        enable = true;
        servers = [
          {
            baseUrl = "http://127.0.0.1:8080/sabnzbd";
            apiKeyFile = config.sec."apiKeys/sabnzbd".path;
          }
        ];
        port = 9387;
      };

      exportarr-sonarr = {
        enable = true;
        apiKeyFile = config.sec."apiKeys/sonarr".path;
        url = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
        port = 9708;
      };

      exportarr-radarr = {
        enable = true;
        apiKeyFile = config.sec."apiKeys/radarr".path;
        url = "http://127.0.0.1:${toString config.services.radarr.settings.server.port}";
        port = 9709;
      };

      exportarr-prowlarr = {
        enable = true;
        apiKeyFile = config.sec."apiKeys/prowlarr".path;
        url = "http://10.200.1.2:${toString config.services.prowlarr.settings.server.port}";
        port = 9710;
      };

      exportarr-lidarr = {
        enable = true;
        apiKeyFile = config.sec."apiKeys/lidarr".path;
        url = "http://127.0.0.1:${toString config.services.lidarr.settings.server.port}";
        port = 9711;
      };

      exportarr-bazarr = {
        enable = true;
        apiKeyFile = config.sec."apiKeys/bazarr".path;
        url = "http://127.0.0.1:${toString config.services.bazarr.listenPort}";
        port = 9712;
      };
    };

    scrapeConfigs = [
      {
        job_name = "thelessone";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
            ];
          }
        ];
      }

      {
        job_name = "arr";
        static_configs = [
          {
            targets =
              map (exporter: "127.0.0.1:${toString config.services.prometheus.exporters.${exporter}.port}")
                [
                  "sabnzbd"
                  "exportarr-sonarr"
                  "exportarr-radarr"
                  "exportarr-prowlarr"
                  "exportarr-lidarr"
                  "exportarr-bazarr"
                ];
          }
        ];
      }
    ];
  };

  services'.caddy.reverseProxies."https://grafana.vpn.theless.one" = {
    port = config.services.grafana.settings.server.http_port;
    vpnOnly = true;
  };
}
