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
  name = "sonarr";

  options.homepage = {
    category = mkDefault "Media services" mkStrOption;
    description = mkDefault "Show manager" mkStrOption;
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
      services'.vopono.allowedTCPPorts = [ config.services.sonarr.settings.server.port ];

      services.sonarr = {
        enable = true;
        inherit (cfg'.lab-config.arr) group;
      };

      services'.caddy.reverseProxies.${domain} = {
        inherit (config.services.sonarr.settings.server) port;
      };

      services'.homepage.categories.${cfg.homepage.category}.services.Sonarr = {
        icon = "sonarr.svg";
        href = domain;
        siteMonitor = domain;
        inherit (cfg.homepage) description;
      };
    };

  dependencies = [
    "caddy"
    "homepage"
    "lab-config"
  ];
}
