{ lib, config, ... }:

let
  inherit (lib.attrsets) filterAttrs;
  inherit (builtins) attrNames map;

  services = attrNames (filterAttrs (_: cfg: cfg.enable) config.services.media-easify.services);

  domain = config.services.caddy-easify.baseDomain;
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

      dns.base_domain = "vpn.theless.one";
      dns.extra_records = map (name: {
        name = "${name}.vpn.theless.one";
        type = "A";
        value = "100.64.64.1";
      }) services;
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  services.caddy-easify.reverseProxies."https://headscale.theless.one" = {
    inherit (config.services.headscale) port;
  };
}
