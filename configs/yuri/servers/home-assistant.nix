{ pkgs, config, ... }:

{
  config'.home-assistant = {
    enable = true;
    homepage = {
      category = "Dienste";
      description = "Smart Home";
    };
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
