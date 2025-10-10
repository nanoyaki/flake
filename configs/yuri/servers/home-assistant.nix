{ pkgs, config, ... }:

{
  config'.home-assistant = {
    enable = true;
    homepage = {
      category = "Dienste";
      description = "Smart Home";
    };
  };

  config'.caddy.vHost."https://home-assistant.nanoyaki.space".enable = false;
  config'.caddy.vHost."zuhause.nanoyaki.space" = {
    proxy.host = "127.0.0.1";
    proxy.port = config.services.home-assistant.config.http.server_port;
    extraConfig = ''
      @web not client_ip private_ranges 10.100.0.0/24 10.0.0.0/24
      respond @web "Forbidden" 403
    '';
  };

  config'.caddy.vHost."http://home-assistant.home.local" = {
    proxy.host = "127.0.0.1";
    proxy.port = config.services.home-assistant.config.http.server_port;
  };

  sops.secrets = {
    "home-assistant/latitudeHome" = { };
    "home-assistant/longitudeHome" = { };
  };

  sops.templates."secrets.yaml" = {
    file = (pkgs.formats.yaml { }).generate "secrets.yaml" {
      latitude_home = config.sops.placeholder."home-assistant/latitudeHome";
      longitude_home = config.sops.placeholder."home-assistant/longitudeHome";
    };

    owner = "hass";
    group = "hass";
    mode = "0440";
    path = "${config.services.home-assistant.configDir}/secrets.yaml";
    restartUnits = [ "home-assistant.service" ];
  };

  services.home-assistant = {
    configDir = "/mnt/nvme-raid-1/var/lib/hass";
    extraComponents = [
      "tplink"
      "tplink_tapo"
      "zha"
    ];

    config = {
      zone = [
        {
          name = "Home";
          latitude = "!secret latitude_home";
          longitude = "!secret longitude_home";
          radius = 25;
          icon = "mdi:home";
        }
      ];

      homeassistant = {
        name = "Zuhause";

        latitude = "!secret latitude_home";
        longitude = "!secret longitude_home";

        unit_system = "metric";
        time_zone = "Europe/Berlin";
      };
    };
  };
}
