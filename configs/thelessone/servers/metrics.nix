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
  };

  services.caddy-easify.reverseProxies."https://grafana.vpn.theless.one" = {
    port = config.services.grafana.settings.server.http_port;
    extraConfig = ''
      @outside-local not client_ip private_ranges 100.64.64.0/18 fd7a:115c:a1e0::/112
      respond @outside-local "Access Denied" 403 {
        close
      }
    '';
  };
}
