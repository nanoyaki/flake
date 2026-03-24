{
  flake.nixosModules.kanokoyuri-hass =
    { config, ... }:

    {
      sops.secrets.hass = {
        path = "${config.services.home-assistant.configDir}/secrets.yaml";
        owner = "hass";
        group = "hass";
        mode = "0440";
        restartUnits = [ "home-assistant.service" ];
      };

      services.caddy.virtualHosts."zuhause.hanakretzer.de" = {
        listenAddresses = [
          "127.0.0.1"
          "::1"
          "10.101.0.1"
          "fd10::1"
          "10.0.0.9"
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
          # "radio_browser"
          "shopping_list"
          # Optimization
          "isal"

          "tplink"
          "tplink_tapo"
          "fitbit"
          "dwd_weather_warnings"
          "mqtt"
        ];

        config = {
          default_config = { };

          recorder.db_url = "postgresql://@/hass";

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
    };
}
