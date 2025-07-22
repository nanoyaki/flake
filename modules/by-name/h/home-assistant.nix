{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib'.options) mkDefault mkStrOption mkFalseOption;

  cfg = config.config'.home-assistant;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.home-assistant = {
    enable = mkFalseOption;

    subdomain = mkDefault "home-assistant" mkStrOption;
    homepage = {
      category = mkDefault "Services" mkStrOption;
      description = mkDefault "Smart home device platform" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    services.home-assistant = {
      enable = true;

      extraComponents = [
        # Onboarding
        "analytics"
        "google_translate"
        "met"
        "radio_browser"
        "shopping_list"

        "isal"
      ];

      config = {
        default_config = { };

        http = {
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

        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        "script ui" = "!include scripts.yaml";
      };
    };

    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
      "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
      "f ${config.services.home-assistant.configDir}/scripts.yaml 0755 hass hass"
    ];

    config'.caddy.reverseProxies.${domain}.port =
      config.services.home-assistant.config.http.server_port;

    config'.homepage.categories.${cfg.homepage.category}.services.Home-assistant = {
      icon = "home-assistant.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
