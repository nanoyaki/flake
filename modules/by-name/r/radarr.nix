{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkFalseOption
    ;

  cfg = config.config'.radarr;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.radarr = {
    enable = mkFalseOption;

    subdomain = mkDefault "radarr" mkStrOption;

    homepage = {
      category = mkDefault "Media services" mkStrOption;
      description = mkDefault "Movie manager" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    config'.vopono.allowedTCPPorts = [ config.services.radarr.settings.server.port ];

    services.radarr = {
      enable = true;
      inherit (config.config'.lab-config.arr) group;
    };

    config'.caddy.vHost.${domain}.proxy = { inherit (config.services.radarr.settings.server) port; };

    config'.homepage.categories.${cfg.homepage.category}.services.Radarr = {
      icon = "radarr.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
