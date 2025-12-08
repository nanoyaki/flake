{ config, ... }:

{
  imports = [
    ./zigbee2mqtt
    ./secrets.nix
    ./db.nix
    ./backups.nix
  ];

  services.caddy.virtualHosts."zuhause.hanakretzer.de" = {
    listenAddresses = [
      "127.0.0.1"
      "::1"
      "10.101.0.1"
      "fd10::1"
      "10.0.0.3"
    ];

    useACMEHost = "hanakretzer.de";
    extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.home-assistant.config.http.server_port}
    '';
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraPackages = ps: with ps; [ psycopg2 ];
    extraComponents = [
      # Onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Optimization
      "isal"

      "tplink"
      "tplink_tapo"
      "fitbit"
      "sleep_as_android"
      "dwd_weather_warnings"
    ];

    config = {
      default_config = { };

      http.use_x_forwarded_for = true;
      http.trusted_proxies = [
        "127.0.0.1"
        "::1"
      ];

      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";

      zone = [
        {
          name = "Home";
          latitude = "!secret latitude_home";
          longitude = "!secret longitude_home";
          radius = 35;
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

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scripts.yaml 0755 hass hass"
  ];
}
