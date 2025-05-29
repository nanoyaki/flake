{
  lib',
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkStrOption
    ;
in

lib'.modules.mkModule {
  name = "paperless";

  options.homepage = {
    category = mkDefault "Services" mkStrOption;
    description = mkDefault "Document management" mkStrOption;
  };

  config =
    {
      cfg,
      config,
      helpers',
      ...
    }:

    let
      domain = helpers'.caddy.domain cfg;
    in

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

      services'.caddy.reverseProxies.${domain} = {
        inherit (config.services.paperless) port;
      };

      services'.homepage.categories.${cfg.homepage.category}.services.Paperless = {
        icon = "paperless.svg";
        href = domain;
        siteMonitor = domain;
        inherit (cfg.homepage) description;
      };
    };

  dependencies = [
    "caddy"
    "homepage"
  ];
}
