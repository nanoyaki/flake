{ config, ... }:

{
  sec."paperless/admin" = { };

  services.paperless = {
    enable = true;
    passwordFile = config.sec."paperless/admin".path;
    consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
    };

    database.createLocally = true;
  };

  services.homepage-easify.categories.Dienste.services.Paperless = rec {
    description = "Dokumente Verwaltung";
    icon = "paperless.svg";
    href = "http://paperless.home.local";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."http://paperless.home.local".port =
    config.services.paperless.port;
}
