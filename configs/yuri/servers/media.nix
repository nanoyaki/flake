{ config, ... }:

let
  mediaServices = "Medien Dienste";
  services = "Dienste";
  media = "Medien";

  varLib = "/mnt/nvme-raid-1/var/lib";
in

{
  services'.caddy.baseDomain = "home.local";
  services'.caddy.useHttps = false;
  services'.caddy.openFirewall = true;

  services = {
    jellyfin.dataDir = "${varLib}/jellyfin";
    immich.mediaLocation = "${varLib}/immich";
    jellyseerr.configDir = "${varLib}/jellyseerr/config";
    prowlarr.dataDir = "${varLib}/prowlarr";
    bazarr.dataDir = "${varLib}/bazarr";
    sabnzbd.configFile = "${varLib}/sabnzbd/sabnzbd.ini";
    transmission.home = "${varLib}/transmission";
    home-assistant.configDir = "${varLib}/hass";
    paperless.dataDir = "${varLib}/paperless";
    sonarr.dataDir = "${varLib}/sonarr/.config/NzbDrone";
    radarr.dataDir = "${varLib}/radarr/.config/Radarr";
    whisparr.dataDir = "${varLib}/whisparr/.config/Whisparr";
  };

  services' = {
    jellyfin = {
      enable = false;
      homepage = {
        category = media;
        description = "Medien archiv";
      };
    };

    immich.homepage = {
      category = media;
      description = "Foto backup software";
    };

    jellyseerr = {
      enable = false;
      homepage = {
        category = mediaServices;
        description = "Film- und Serien-Anfragen";
      };
    };

    prowlarr = {
      enable = false;
      homepage = {
        category = mediaServices;
        description = "Indexing manager";
      };
    };

    bazarr = {
      enable = false;
      homepage = {
        category = mediaServices;
        description = "Untertitel manager";
      };
    };

    lidarr = {
      enable = false;
      homepage.category = mediaServices;
      homepage.description = "Musik manager";
    };

    whisparr.enable = true;

    radarr = {
      enable = false;
      homepage = {
        category = mediaServices;
        description = "Filme manager";
      };
    };

    sonarr = {
      enable = false;
      homepage = {
        category = mediaServices;
        description = "Serien manager";
      };
    };

    sabnzbd = {
      enable = false;
      homepage.category = services;
    };

    transmission = {
      enable = false;
      homepage.category = services;
    };

    paperless.homepage = {
      category = services;
      description = "Dokumente management";
    };

    home-assistant.homepage = {
      category = services;
      description = "Smart Home";
    };

    vaultwarden = {
      enable = false;

      homepage = {
        category = services;
        description = "Lokaler Passwortmanager";
      };
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

    vopono.dataDir = "${varLib}/vopono";
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
