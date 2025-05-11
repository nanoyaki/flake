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

  service = "prowlarr";

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
        default = "Media services";
      };

      description = mkOption {
        type = types.str;
        default = "Indexing manager";
      };
    };
  };

  config = mkIf cfg.enable {
    services.vopono.services.${service} = config.services.${service}.settings.server.port;

    services.${service} = {
      enable = true;
      inherit (cfg) openFirewall;
    };

    services.caddy-easify.reverseProxies.${domain} = {
      inherit (config.services.${service}.settings.server) port;
      host = "10.200.1.2";
    };

    services.homepage-easify.categories.${cfg.homepage.category}.services.${toUppercase service} = {
      icon = "${service}.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
