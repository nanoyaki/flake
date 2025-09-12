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

  cfg = config.config'.sonarr;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.sonarr = {
    enable = mkFalseOption;

    subdomain = mkDefault "sonarr" mkStrOption;
    homepage = {
      category = mkDefault "Media services" mkStrOption;
      description = mkDefault "Show manager" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    config'.vopono.allowedTCPPorts = [ config.services.sonarr.settings.server.port ];

    services.sonarr = {
      enable = true;
      inherit (config.config'.lab-config.arr) group;
    };

    config'.caddy.vHost.${domain}.proxy = { inherit (config.services.sonarr.settings.server) port; };

    config'.homepage.categories.${cfg.homepage.category}.services.Sonarr = {
      icon = "sonarr.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
