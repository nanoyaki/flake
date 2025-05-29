{
  lib,
  lib',
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib'.options) mkDefault mkTrueOption mkStrOption;
in

lib'.modules.mkModule {
  name = "immich";

  options = {
    enableHardwareAcceleration = mkTrueOption;

    homepage = {
      category = mkDefault "Media" mkStrOption;
      description = mkDefault "Photo backups" mkStrOption;
    };
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
      services.immich = {
        enable = true;
        accelerationDevices = mkIf cfg.enableHardwareAcceleration [ "/dev/dri/renderD128" ];
      };

      services'.caddy.reverseProxies.${domain} = { inherit (config.services.immich) port; };

      services'.homepage.categories.${cfg.homepage.category}.services.Immich = {
        icon = "immich.svg";
        href = domain;
        siteMonitor = domain;
        inherit (cfg.homepage) description;
      };

      users.users.${config.services.immich.user}.extraGroups = [
        "video"
        "render"
      ];
    };

  dependencies = [
    "caddy"
    "homepage"
  ];
}
