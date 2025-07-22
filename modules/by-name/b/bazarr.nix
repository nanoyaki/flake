{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib'.options) mkDefault mkStrOption mkFalseOption;
  inherit (config.config'.lab-config) arr;

  cfg = config.config'.bazarr;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.bazarr = {
    enable = mkFalseOption;

    subdomain = mkDefault "bazarr" mkStrOption;
    homepage = {
      category = mkDefault "Media services" mkStrOption;
      description = mkDefault "Subtitle manager" mkStrOption;
    };
  };

  config = lib.mkIf cfg.enable {
    services.bazarr = {
      enable = true;
      inherit (arr) group;
    };

    config'.caddy.reverseProxies.${domain}.port = config.services.bazarr.listenPort;

    config'.homepage.categories.${cfg.homepage.category}.services.Bazarr = {
      icon = "bazarr.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
