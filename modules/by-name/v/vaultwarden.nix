{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkFalseOption
    ;

  inherit (lib) mkIf;

  cfg = config.config'.vaultwarden;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.vaultwarden = {
    enable = mkFalseOption;

    subdomain = mkDefault "vaultwarden" mkStrOption;
    homepage = {
      category = mkDefault "Services" mkStrOption;
      description = mkDefault "Local bitwarden server" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      backupDir = "/var/backup/vaultwarden";

      config = {
        DOMAIN = domain;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };

    config'.caddy.vHost.${domain}.proxy.port = config.services.vaultwarden.config.ROCKET_PORT;

    config'.homepage.categories.${cfg.homepage.category}.services.Vaultwarden = {
      icon = "bitwarden.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
