{ self, ... }:

let
  mediaServices = "Medien Dienste";
  services = "Dienste";
  media = "Medien";
in

{
  imports = [ self.nixosModules.media-easify ];

  services.caddy-easify.useHttps = false;

  services.media-easify.services = {
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
  };

  services.homepage-easify = {
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

  services.home-assistant.extraComponents = [
    "tplink"
    "tplink_tapo"
  ];
}
