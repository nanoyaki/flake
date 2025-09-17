{ pkgs, ... }:

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

    flaresolverr.enable = true;

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

  services.prowlarr.package = pkgs.prowlarr.overrideAttrs { doCheck = false; };

  services.transmission.settings = {
    speed-limit-down-enabled = true;
    speed-limit-down = 2000;
    speed-limit-up-enabled = true;
    speed-limit-up = 1000;
  };
}
