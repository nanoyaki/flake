{ pkgs, config, ... }:

{
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

  sops.secrets.hass = {
    path = "${config.services.home-assistant.configDir}/secrets.yaml";
    owner = "hass";
    group = "hass";
    mode = "0440";
    restartUnits = [ "home-assistant.service" ];
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      card-mod
      mini-graph-card
      mini-media-player
    ];

    extraPackages = ps: with ps; [ psycopg2 ];
    extraComponents = [
      # Onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"

      "isal"

      "tplink"
      "tplink_tapo"
      "mqtt"
      "fitbit"
      "sleep_as_android"
      "dwd_weather_warnings"
    ];

    config = {
      default_config = { };

      recorder.db_url = "postgresql://@/hass";

      http = {
        server_host = [
          "0.0.0.0"
          "::"
        ];

        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];

        use_x_forwarded_for = true;
      };

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

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" ];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scripts.yaml 0755 hass hass"
  ];
}
