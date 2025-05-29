{
  lib,
  lib',
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkPathOption
    ;

  inherit (lib) genAttrs;
in

lib'.modules.mkModule {
  name = "sabnzbd";

  options =
    { cfg', ... }:

    let
      inherit (cfg'.lab-config.arr) home;
    in

    {
      completeDirectory = mkDefault "${home}/downloads/complete" mkPathOption;
      incompleteDirectory = mkDefault "${home}/downloads/incomplete" mkPathOption;

      homepage = {
        category = mkDefault "Services" mkStrOption;
        description = mkDefault "Usenet client" mkStrOption;
      };
    };

  config =
    {
      cfg,
      cfg',
      config,
      helpers',
      ...
    }:

    let
      domain = helpers'.caddy.domain cfg;
    in

    {
      services.sabnzbd = {
        enable = true;
        inherit (cfg'.lab-config.arr) group;
      };

      services'.caddy.reverseProxies.${domain}.port = 8080;

      services'.homepage.categories.${cfg.homepage.category}.services.Sabnzbd = {
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
              inherit (cfg'.lab-config.arr) group;
              mode = "2770";
            };
          });
    };

  dependencies = [
    "caddy"
    "homepage"
    "lab-config"
  ];
}
