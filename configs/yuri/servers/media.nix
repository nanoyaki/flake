{ pkgs, config, ... }:

let
  mediaServices = "Medien Dienste";
  services = "Dienste";
  media = "Medien";

  varLib = "/mnt/nvme-raid-1/var/lib";
in

{
  config'.caddy = {
    enable = true;

    baseDomain = "home.local";
    useHttps = false;
    openFirewall = true;
  };

  services.caddy = {
    dataDir = "${varLib}/caddy";
    logDir = "/mnt/nvme-raid-1/var/log/caddy";
  };

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

  config' = {
    jellyfin = {
      enable = false;
      homepage = {
        category = media;
        description = "Medien archiv";
      };
    };

    immich.enable = true;
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
      enable = true;
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
      enable = true;
      homepage.category = services;
    };

    transmission = {
      enable = true;
      homepage.category = services;
    };

    paperless.enable = true;
    paperless.homepage = {
      category = services;
      description = "Dokumente management";
    };

    home-assistant.enable = true;
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

    homepage.enable = true;
    homepage = {
      categories = {
        ${services}.before = media;
        ${media}.before = mediaServices;
      };

      glances.widgets = [
        { Info.metric = "info"; }
        { Speicherplatz.metric = "fs:/"; }
        { "CPU Auslastung".metric = "cpu"; }
        { Netzwerk.metric = "network:enp7s0"; }
      ];
    };

    lab-config.enable = true;

    vopono.enable = true;
    vopono.dataDir = "${varLib}/vopono";
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
