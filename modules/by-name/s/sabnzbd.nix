{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) genAttrs mkIf;
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkPathOption
    mkFalseOption
    ;

  inherit (config.config'.lab-config) arr;

  cfg = config.config'.sabnzbd;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.sabnzbd = {
    enable = mkFalseOption;

    subdomain = mkDefault "sabnzbd" mkStrOption;

    completeDirectory = mkDefault "${arr.home}/downloads/complete" mkPathOption;
    incompleteDirectory = mkDefault "${arr.home}/downloads/incomplete" mkPathOption;

    homepage = {
      category = mkDefault "Services" mkStrOption;
      description = mkDefault "Usenet client" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    config'.vopono.allowedTCPPorts = [ 8080 ];

    services.sabnzbd = {
      enable = true;
      inherit (arr) group;
    };

    config'.caddy.reverseProxies.${domain}.port = 8080;

    config'.homepage.categories.${cfg.homepage.category}.services.Sabnzbd = {
      icon = "sabnzbd.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };

    systemd.tmpfiles.settings."10-sabnzbd" =
      genAttrs [ cfg.completeDirectory cfg.incompleteDirectory ]
        (_: {
          d = {
            inherit (config.services.sabnzbd) user;
            inherit (arr) group;
            mode = "2770";
          };
        });
  };
}
