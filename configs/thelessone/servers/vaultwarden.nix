{ config, ... }:

{
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    config = {
      DOMAIN = "https://vaultwarden.theless.one";

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };

  services.homepage-easify.categories.Services.services.Vaultwarden = rec {
    description = "Local Bitwarden server";
    icon = "bitwarden.svg";
    href = "https://vaultwarden.theless.one";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."vaultwarden.theless.one".port =
    config.services.vaultwarden.config.ROCKET_PORT;
}
