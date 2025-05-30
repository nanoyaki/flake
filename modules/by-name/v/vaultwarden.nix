{
  lib,
  lib',
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkStrOption
    ;

  inherit (lib) optionalString;
in

lib'.modules.mkModule {
  name = "vaultwarden";

  options.homepage = {
    category = mkDefault "Services" mkStrOption;
    description = mkDefault "Local bitwarden server" mkStrOption;
  };

  config =
    {
      cfg,
      cfg',
      config,
      helpers',
      ...
    }:

    let
      domain = helpers'.caddy.domain cfg;
    in

    {
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

      services'.caddy.reverseProxies.${domain} = {
        port = config.services.vaultwarden.config.ROCKET_PORT;
        extraConfig = optionalString (!cfg'.caddy.useHttps) ''
          tls internal
        '';
      };

      services'.homepage.categories.${cfg.homepage.category}.services.Vaultwarden = {
        icon = "bitwarden.svg";
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
