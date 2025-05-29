{ config, ... }:

{
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
  };

  services'.caddy.reverseProxies."https://grafana.vpn.theless.one" = {
    port = config.services.grafana.settings.server.http_port;
    vpnOnly = true;
  };
}
