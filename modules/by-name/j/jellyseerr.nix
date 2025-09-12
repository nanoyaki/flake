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

  cfg = config.config'.jellyseerr;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.jellyseerr = {
    enable = mkFalseOption;

    subdomain = mkDefault "jellyseerr" mkStrOption;

    homepage = {
      category = mkDefault "Media services" mkStrOption;
      description = mkDefault "Movie and show requests" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    services.jellyseerr.enable = true;

    config'.caddy.vHost.${domain}.proxy = { inherit (config.services.jellyseerr) port; };

    config'.homepage.categories.${cfg.homepage.category}.services.Jellyseerr = {
      icon = "jellyseerr.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
