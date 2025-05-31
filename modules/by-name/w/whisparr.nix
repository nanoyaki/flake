{ lib', ... }:

let
  inherit (lib'.options)
    mkDefault
    mkStrOption
    ;
in

lib'.modules.mkModule {
  name = "whisparr";

  options.homepage = {
    category = mkDefault "Media services" mkStrOption;
    description = mkDefault "Adult video manager" mkStrOption;
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
      services'.vopono.allowedTCPPorts = [ config.services.whisparr.settings.server.port ];

      services.whisparr = {
        enable = true;
        inherit (cfg'.lab-config.arr) group;
      };

      services'.caddy.reverseProxies.${domain}.port = config.services.whisparr.settings.server.port;

      services'.homepage.categories.${cfg.homepage.category}.services.Whisparr = {
        icon = "whisparr.svg";
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
