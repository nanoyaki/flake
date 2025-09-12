{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkFalseOption
    ;

  cfg = config.config'.paperless;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in
{
  options.config'.paperless = {
    enable = mkFalseOption;

    subdomain = mkDefault "paperless" mkStrOption;

    homepage = {
      category = mkDefault "Services" mkStrOption;
      description = mkDefault "Document management" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.paperless-admin = { };

    services.paperless = {
      enable = true;
      passwordFile = config.sops.secrets.paperless-admin.path;
      inherit domain;

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

    config'.caddy.vHost.${domain}.proxy = { inherit (config.services.paperless) port; };

    config'.homepage.categories.${cfg.homepage.category}.services.Paperless = {
      icon = "paperless.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
