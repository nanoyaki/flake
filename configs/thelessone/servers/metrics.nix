{ lib, config, ... }:

let
  inherit (lib.lists) map;
in

{
  sops.secrets = {
    "apiKeys/sabnzbd" = { };
    "apiKeys/sonarr" = { };
    "apiKeys/radarr" = { };
    "apiKeys/prowlarr" = { };
    "apiKeys/lidarr" = { };
    "apiKeys/bazarr" = { };
    "apiKeys/woodpecker".owner = "prometheus";
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 2342;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.theless.one";
      };

      analytics.reporting_enabled = false;
    };

    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;

        datasources = [
          {
            name = "prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
          }
        ];
      };
    };
  };

  config'.caddy.vHost."https://grafana.theless.one" = {
    proxy.port = config.services.grafana.settings.server.http_port;
    useMtls = true;
  };

  services.prometheus = {
    enable = true;
    port = 9092;
    checkConfig = "syntax-only";

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

      nvidia-gpu = {
        enable = true;
        port = 9835;
      };

      sabnzbd = {
        enable = true;
        servers = [
          {
            baseUrl = "http://127.0.0.1:8080/";
            apiKeyFile = config.sops.secrets."apiKeys/sabnzbd".path;
          }
        ];
        port = 9387;
      };

      exportarr-sonarr = {
        enable = true;
        apiKeyFile = config.sops.secrets."apiKeys/sonarr".path;
        url = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
        port = 9708;
      };

      exportarr-radarr = {
        enable = true;
        apiKeyFile = config.sops.secrets."apiKeys/radarr".path;
        url = "http://127.0.0.1:${toString config.services.radarr.settings.server.port}";
        port = 9709;
      };

      exportarr-prowlarr = {
        enable = true;
        apiKeyFile = config.sops.secrets."apiKeys/prowlarr".path;
        url = "http://10.200.1.2:${toString config.services.prowlarr.settings.server.port}";
        port = 9710;
      };

      exportarr-lidarr = {
        enable = true;
        apiKeyFile = config.sops.secrets."apiKeys/lidarr".path;
        url = "http://127.0.0.1:${toString config.services.lidarr.settings.server.port}";
        port = 9711;
      };

      exportarr-bazarr = {
        enable = true;
        apiKeyFile = config.sops.secrets."apiKeys/bazarr".path;
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
              "127.0.0.1:${toString config.services.prometheus.exporters.nvidia-gpu.port}"
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

      {
        job_name = "woodpecker";
        bearer_token_file = config.sops.secrets."apiKeys/woodpecker".path;
        static_configs = [ { targets = [ "woodpecker.theless.one" ]; } ];
      }
    ];
  };

  services.loki = rec {
    enable = true;
    dataDir = "/var/lib/loki";
    configuration = {
      server.http_listen_port = 3030;
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore.store = "inmemory";
            replication_factor = 1;
          };
        };
        chunk_idle_period = "24h";
        max_chunk_age = "24h";
        chunk_target_size = 999999;
        chunk_retain_period = "30s";
      };

      schema_config.configs = [
        {
          from = "2025-06-03";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "${dataDir}/tsdb-index";
          cache_location = "${dataDir}/tsdb-cache";
          cache_ttl = "24h";
        };

        filesystem.directory = "${dataDir}/chunks";
      };

      query_scheduler.max_outstanding_requests_per_tenant = 32768;
      querier.max_concurrent = 16;

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };

      compactor = {
        working_directory = dataDir;
        compactor_ring.kvstore.store = "inmemory";
      };
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };

      positions.filename = "/tmp/positions.yaml";

      clients = [ { url = "http://127.0.0.1:3030/loki/api/v1/push"; } ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "24h";
            labels = {
              job = "systemd-journal";
              host = "thelessone";
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };
}
