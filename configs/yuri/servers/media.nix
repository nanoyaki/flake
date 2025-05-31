{ config, ... }:

let
  mediaServices = "Medien Dienste";
  services = "Dienste";
  media = "Medien";
in

{
  services'.caddy.baseDomain = "home.local";
  services'.caddy.useHttps = false;

  services' = {
    jellyfin.homepage = {
      category = media;
      description = "Medien archiv";
    };

    immich.homepage = {
      category = media;
      description = "Foto backup software";
    };

    jellyseerr.homepage = {
      category = mediaServices;
      description = "Film- und Serien-Anfragen";
    };

    prowlarr.homepage = {
      category = mediaServices;
      description = "Indexing manager";
    };

    bazarr.homepage = {
      category = mediaServices;
      description = "Untertitel manager";
    };

    lidarr = {
      enable = false;
      homepage.category = mediaServices;
      homepage.description = "Musik manager";
    };

    whisparr.enable = false;

    radarr.homepage = {
      category = mediaServices;
      description = "Filme manager";
    };

    sonarr.homepage = {
      category = mediaServices;
      description = "Serien manager";
    };

    sabnzbd.homepage.category = services;

    transmission.homepage.category = services;

    paperless.homepage = {
      category = services;
      description = "Dokumente management";
    };

    home-assistant.homepage = {
      category = services;
      description = "Smart Home";
    };

    vaultwarden.homepage = {
      category = services;
      description = "Lokaler Passwortmanager";
    };

    homepage = {
      categories = {
        ${services}.before = media;
        ${media}.before = mediaServices;
      };

      glances.widgets = [
        { Info.metric = "info"; }
        { Speicherplatz.metric = "fs:/"; }
        { "CPU Auslastung".metric = "cpu"; }
        { Netzwerk.metric = "network:enp4s0"; }
      ];
    };
  };

  sec."home-assistant/secrets" = {
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

  services.transmission.settings = {
    speed-limit-down-enabled = true;
    speed-limit-down = 2000;
    speed-limit-up-enabled = true;
    speed-limit-up = 1000;
  };
}
