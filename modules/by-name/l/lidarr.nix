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
  name = "lidarr";

  options.homepage = {
    category = mkDefault "Media services" mkStrOption;
    description = mkDefault "Music manager" mkStrOption;
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
      services'.vopono.allowedTCPPorts = [ config.services.lidarr.settings.server.port ];

      services.lidarr = {
        enable = true;
        inherit (cfg'.lab-config.arr) group;
      };

      services'.caddy.reverseProxies.${domain} = {
        inherit (config.services.lidarr.settings.server) port;
      };

      services'.homepage.categories.${cfg.homepage.category}.services.Lidarr = {
        icon = "lidarr.svg";
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
