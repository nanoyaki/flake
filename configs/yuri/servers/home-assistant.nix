{ pkgs, config, ... }:

let
  domain = "https://zuhause.nanoyaki.space";
in

{
  # Backwards compatibility
  config'.caddy.vHost."http://home-assistant.home.local" = {
    proxy.host = "127.0.0.1";
    proxy.port = config.services.home-assistant.config.http.server_port;
  };

  config'.caddy.vHost.${domain} = {
    proxy.host = "127.0.0.1";
    proxy.port = config.services.home-assistant.config.http.server_port;
    extraConfig = ''
      @web not client_ip private_ranges 10.100.0.0/24 10.0.0.0/24
      respond @web "Forbidden" 403
    '';
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
    enable = true;

    configDir = "/mnt/nvme-raid-1/var/lib/hass";
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
      "zha"
    ];

    config = {
      default_config = { };

      http = {
        server_host = [
          "127.0.0.1"
          "::1"
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

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scripts.yaml 0755 hass hass"
  ];

  config'.homepage.categories.Dienste.services.Home-assistant = {
    icon = "home-assistant.svg";
    href = domain;
    siteMonitor = domain;
    description = "Smart home Gerätemanager und alles andere ums Zuhause";
  };
}
