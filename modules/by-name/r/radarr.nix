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
  name = "radarr";

  options.homepage = {
    category = mkDefault "Media services" mkStrOption;
    description = mkDefault "Movie manager" mkStrOption;
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
      services'.vopono.allowedTCPPorts = [ config.services.radarr.settings.server.port ];

      services.radarr = {
        enable = true;
        inherit (cfg'.lab-config.arr) group;
      };

      services'.caddy.reverseProxies.${domain} = {
        inherit (config.services.radarr.settings.server) port;
      };

      services'.homepage.categories.${cfg.homepage.category}.services.Radarr = {
        icon = "radarr.svg";
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
