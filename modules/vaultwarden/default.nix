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

  service = "vaultwarden";

  cfg = config.services.media-easify.services.${service};

  subdomain = optionalString cfg.useSubdomain "${cfg.subdomain}.";
  slug = optionalString cfg.useDomainSlug "/${cfg.domainSlug}";
  inherit (config.services.caddy-easify) baseDomain;

  domain = "https://${subdomain}${baseDomain}${slug}";
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

    openFirewall = mkEnableOption "opening the firewall for ${service}";

    homepage = {
      category = mkOption {
        type = types.str;
        default = "Services";
      };

      description = mkOption {
        type = types.str;
        default = "Local bitwarden server";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      config.services.${service}.config.ROCKET_PORT
    ];

    services.${service} = {
      enable = true;
      dbBackend = "sqlite";

      config = {
        DOMAIN = domain;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };

    services.caddy-easify.reverseProxies.${domain} = {
      port = config.services.${service}.config.ROCKET_PORT;
      extraConfig = optionalString (!config.services.caddy-easify.useHttps) ''
        tls internal
      '';
    };

    services.homepage-easify.categories.${cfg.homepage.category}.services.${toUppercase service} = {
      icon = "bitwarden.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
