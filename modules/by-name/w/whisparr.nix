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

  specialArgs = [ "packages" ];
  config =
    {
      cfg,
      cfg',
      config,
      packages,
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
        package = packages.whisparr;
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
