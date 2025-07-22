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

  cfg = config.config'.lidarr;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.lidarr = {
    enable = mkFalseOption;

    subdomain = mkDefault "lidarr" mkStrOption;

    homepage = {
      category = mkDefault "Media services" mkStrOption;
      description = mkDefault "Music manager" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    config'.vopono.allowedTCPPorts = [ config.services.lidarr.settings.server.port ];

    services.lidarr = {
      enable = true;
      inherit (config.config'.lab-config.arr) group;
    };

    config'.caddy.reverseProxies.${domain} = {
      inherit (config.services.lidarr.settings.server) port;
    };

    config'.homepage.categories.${cfg.homepage.category}.services.Lidarr = {
      icon = "lidarr.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
