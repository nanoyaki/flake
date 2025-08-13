{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib'.options)
    mkDefault
    mkTrueOption
    mkStrOption
    mkFalseOption
    ;

  cfg = config.config'.immich;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.immich = {
    enable = mkFalseOption;
    enableHardwareAcceleration = mkTrueOption;

    subdomain = mkDefault "immich" mkStrOption;

    homepage = {
      category = mkDefault "Media" mkStrOption;
      description = mkDefault "Photo backups" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      package = pkgs.immich.override {
        sourcesJSON = ./sources.json;
      };
      accelerationDevices = mkIf cfg.enableHardwareAcceleration [ "/dev/dri/renderD128" ];
    };

    config'.caddy.reverseProxies.${domain} = { inherit (config.services.immich) port; };

    config'.homepage.categories.${cfg.homepage.category}.services.Immich = {
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
}
