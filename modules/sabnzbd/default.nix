{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    optionalString
    ;

  inherit (lib') mkEnabledOption toUppercase;

  service = "sabnzbd";

  cfg = config.services.media-easify.services.${service};

  subdomain = optionalString cfg.useSubdomain "${cfg.subdomain}.";
  slug = optionalString cfg.useDomainSlug "/${cfg.domainSlug}";
  inherit (config.services.caddy-easify) baseDomain;
  scheme = "http${optionalString config.services.caddy-easify.useHttps "s"}://";

  domain = "${scheme}${subdomain}${baseDomain}${slug}";

  dirCfg = {
    inherit (config.services.sabnzbd) user;
    inherit (config.services.media-easify) group;
    mode = "2770";
  };
in

{
  options.services.media-easify.services.${service} = {
    enable = mkEnabledOption service;

    useSubdomain = mkEnabledOption "a subdomain for ${service}";

    subdomain = mkOption {
      type = types.str;
      default = service;
    };

    useDomainSlug = mkEnableOption "the domain slug for ${service}";

    domainSlug = mkOption {
      type = types.str;
      default = service;
    };

    openFirewall = mkEnabledOption "opening the firewall for ${service}";

    homepage = {
      category = mkOption {
        type = types.str;
        default = "Services";
      };

      description = mkOption {
        type = types.str;
        default = "Usenet client";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 8080 ];

    services.${service} = {
      enable = true;
      inherit (config.services.media-easify) group;
    };

    services.caddy-easify.reverseProxies.${domain}.port = 8080;

    services.homepage-easify.categories.${cfg.homepage.category}.services.${toUppercase service} = {
      icon = "${service}.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };

    systemd.tmpfiles.settings."10-${service}" = {
      "/home/arr-stack/downloads/complete".d = dirCfg;
      "/home/arr-stack/downloads/incomplete".d = dirCfg;
    };
  };
}
