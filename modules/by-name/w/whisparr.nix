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

  cfg = config.config'.whisparr;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.whisparr = {
    enable = mkFalseOption;

    subdomain = mkDefault "whisparr" mkStrOption;
    homepage = {
      enable = mkFalseOption;

      category = mkDefault "Media services" mkStrOption;
      description = mkDefault "Adult video manager" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    config'.vopono.allowedTCPPorts = [ config.services.whisparr.settings.server.port ];

    services.whisparr = {
      enable = true;
      inherit (config.config'.lab-config.arr) group;
    };

    config'.caddy.vHost.${domain}.proxy.port = config.services.whisparr.settings.server.port;

    config'.homepage = mkIf cfg.homepage.enable {
      categories.${cfg.homepage.category}.services.Whisparr = {
        icon = "whisparr.svg";
        href = domain;
        siteMonitor = domain;
        inherit (cfg.homepage) description;
      };
    };
  };
}
