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

  cfg = config.config'.prowlarr;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in
{
  options.config'.prowlarr = {
    enable = mkFalseOption;

    subdomain = mkDefault "prowlarr" mkStrOption;

    homepage = {
      category = mkDefault "Media services" mkStrOption;
      description = mkDefault "Indexing manager" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    config'.vopono.services.prowlarr = [ config.services.prowlarr.settings.server.port ];

    systemd.services.prowlarr.wantedBy = lib.mkForce [ "vopono.service" ];
    services.prowlarr = {
      enable = true;
      openFirewall = true;
    };

    config'.caddy.vHost.${domain}.proxy = {
      inherit (config.services.prowlarr.settings.server) port;
      inherit (config.config'.vopono) host;
    };

    config'.homepage.categories.${cfg.homepage.category}.services.Prowlarr = {
      icon = "prowlarr.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
