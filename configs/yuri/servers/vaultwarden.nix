{ config, ... }:

{
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    config = {
      DOMAIN = "https://vaultwarden.home.local";

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };

  services.homepage-easify.categories.Dienste.services.Vaultwarden = rec {
    description = "Lokal betriebener Bitwarden Server";
    icon = "bitwarden.svg";
    href = "https://vaultwarden.home.local";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."https://vaultwarden.home.local" = {
    port = config.services.vaultwarden.config.ROCKET_PORT;
    extraConfig = ''
      tls internal
    '';
  };
}
