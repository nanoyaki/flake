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
in

lib'.modules.mkModule {
  name = "prowlarr";

  options.homepage = {
    category = mkDefault "Media services" mkStrOption;
    description = mkDefault "Indexing manager" mkStrOption;
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
      services'.vopono = {
        services.prowlarr = [ config.services.prowlarr.settings.server.port ];
        allowedTCPPorts = [
          config.services.radarr.settings.server.port
          config.services.sonarr.settings.server.port
          config.services.flaresolverr.port
        ];
      };

      services.flaresolverr.enable = lib.mkDefault true;

      systemd.services.prowlarr.wantedBy = lib.mkForce [ "vopono.service" ];
      services.prowlarr = {
        enable = true;
        openFirewall = true;
      };

      services'.caddy.reverseProxies.${domain} = {
        inherit (config.services.prowlarr.settings.server) port;
        host = "10.200.1.2";
      };

      services'.homepage.categories.${cfg.homepage.category}.services.Prowlarr = {
        icon = "prowlarr.svg";
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
