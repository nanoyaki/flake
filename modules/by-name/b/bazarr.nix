{ lib', ... }:

let
  inherit (lib'.options) mkDefault mkStrOption;
in

lib'.modules.mkModule {
  name = "bazarr";

  options.homepage = {
    category = mkDefault "Media services" mkStrOption;
    description = mkDefault "Subtitle manager" mkStrOption;
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
      services.bazarr = {
        enable = true;
        inherit (cfg'.lab-config.arr) group;
      };

      services'.caddy.reverseProxies.${domain}.port = config.services.bazarr.listenPort;

      services'.homepage.categories.${cfg.homepage.category}.services.Bazarr = {
        icon = "bazarr.svg";
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
