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

  service = "home-assistant";

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
        default = "Services";
      };

      description = mkOption {
        type = types.str;
        default = "Smart home device platform";
      };
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;
      inherit (cfg) openFirewall;

      extraComponents = [
        "analytics"
        "google_translate"
        "met"
        "radio_browser"
        "shopping_list"

        "isal"
      ];

      config.default_config = { };

      config.http = {
        server_host = [
          "127.0.0.1"
          "::1"
        ];

        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];

        use_x_forwarded_for = true;
      };
    };

    services.caddy-easify.reverseProxies.${domain}.port =
      config.services.home-assistant.config.http.server_port;

    services.homepage-easify.categories.${cfg.homepage.category}.services.${toUppercase service} = {
      icon = "${service}.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
