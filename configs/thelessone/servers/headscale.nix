{ lib, config, ... }:

let
  inherit (lib.attrsets) filterAttrs;
  inherit (builtins) attrNames map;

  domain = config.config'.caddy.baseDomain;
in

{
  services.headscale = {
    enable = true;

    address = "0.0.0.0";
    port = 3004;

    settings = {
      server_url = "http://headscale.${domain}";

      prefixes.v4 = "100.64.64.0/18";
      prefixes.v6 = "fd7a:115c:a1e0::/112";

      log.level = "warn";
      logtail.enabled = false;
      metrics_listen_addr = "127.0.0.1:9090";

      dns = {
        override_local_dns = false;
        base_domain = "vpn.${domain}";
        extra_records = map (name: {
          name = "${name}.vpn.${domain}";
          type = "A";
          value = "100.64.64.1";
        }) (attrNames (filterAttrs (_: cfg: cfg ? enable && cfg.enable && cfg ? subdomain) config.config'));
      };

      randomize_client_port = true;
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  config'.caddy.vHost."https://headscale.${domain}".proxy = {
    inherit (config.services.headscale) port;
  };
}
