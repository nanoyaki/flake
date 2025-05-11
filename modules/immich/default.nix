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

  service = "immich";

  cfg = config.services.media-easify.services.${service};

  subdomain = optionalString cfg.useSubdomain "${cfg.subdomain}.";
  slug = optionalString cfg.useDomainSlug "/${cfg.domainSlug}";
  inherit (config.services.caddy-easify) baseDomain;
  scheme = if config.services.caddy-easify.useHttps then "https://" else "http://";

  domain = "${scheme}${subdomain}${baseDomain}${slug}";
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
        default = "Media";
      };

      description = mkOption {
        type = types.str;
        default = "Picture backups";
      };
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;
      inherit (cfg) openFirewall;
    };

    services.caddy-easify.reverseProxies.${domain} = {
      inherit (config.services.${service}) port;
    };

    services.homepage-easify.categories.${cfg.homepage.category}.services.${toUppercase service} = {
      icon = "${service}.svg";
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
