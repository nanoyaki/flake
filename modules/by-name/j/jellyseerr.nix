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
  name = "jellyseerr";

  options.homepage = {
    category = mkDefault "Media services" mkStrOption;
    description = mkDefault "Movie and show requests" mkStrOption;
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
      services.jellyseerr.enable = true;

      services'.caddy.reverseProxies.${domain} = {
        inherit (config.services.jellyseerr) port;
      };

      services'.homepage.categories.${cfg.homepage.category}.services.Jellyseerr = {
        icon = "jellyseerr.svg";
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
