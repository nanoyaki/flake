{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.home-assistant ];
  };

  modules.nixos.home-assistant =
    { config, ... }:

    let
      cfg = config.services.home-assistant;
    in

    {
      networking.firewall.allowedTCPPorts = [ 8123 ];
      services.home-assistant = {
        enable = true;
        extraPackages = ps: with ps; [ psycopg2 ];
        extraComponents = [
          # Onboarding
          "analytics"
          "google_translate"
          "met"
          "radio_browser"
          "shopping_list"
          # Optimization
          "isal"

          "tplink"
          "tplink_tapo"
          "fitbit"
          "dwd_weather_warnings"
          "mqtt"
        ];

        config = {
          default_config = { };

          "automation ui" = "!include automations.yaml";
          "scene ui" = "!include scenes.yaml";
          "script ui" = "!include scripts.yaml";

          zone = [
            {
              name = "Home";
              latitude = "!secret latitude_home";
              longitude = "!secret longitude_home";
              radius = 35;
              icon = "mdi:home";
            }
          ];

          homeassistant = {
            name = "Zuhause";

            latitude = "!secret latitude_home";
            longitude = "!secret longitude_home";

            unit_system = "metric";
            time_zone = "Europe/Berlin";
          };
        };
      };

      systemd.tmpfiles.rules = [
        "f ${cfg.configDir}/automations.yaml 0755 hass hass"
        "f ${cfg.configDir}/scenes.yaml 0755 hass hass"
        "f ${cfg.configDir}/scripts.yaml 0755 hass hass"
      ];
    };

  modules.nixos.rustic =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;

      cfg = config.services.home-assistant;
    in

    {
      config = mkIf cfg.enable {
        services.rustic.backups.home-assistant = {
          paths = [ cfg.configDir ];
          exclude = [ "${cfg.configDir}/.cache" ];

          backup.hooks = {
            run-before = [
              (pkgs.writeShellScript "rustic-hass-stop.sh" ''
                /run/current-system/sw/bin/systemctl stop home-assistant
              '').outPath
            ];
            run-after = [
              (pkgs.writeShellScript "rustic-hass-start.sh" ''
                /run/current-system/sw/bin/systemctl start home-assistant
              '').outPath
            ];
          };
        };
      };
    };

  modules.nixos.caddy =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      cfg = config.services.home-assistant;
    in

    {
      config = mkIf cfg.enable {
        # Sadly you can no longer configure the port declaratively :(
        services.caddy.virtualHosts."zuhause.hanakretzer.de".extraConfig = ''
          reverse_proxy [::1]:8123
        '';
      };
    };

  modules.nixos.tailscale =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      cfg = config.services.home-assistant;
    in

    {
      config = mkIf (cfg.enable && config.services.caddy.enable) {
        services.caddy.virtualHosts."zuhause.hanakretzer.de".tailnetOnly = true;
      };
    };

  modules.nixos.acme =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      cfg = config.services.home-assistant;
    in

    {
      config = mkIf (cfg.enable && config.services.caddy.enable) {
        services.caddy.virtualHosts."zuhause.hanakretzer.de".useACMEHost = "hanakretzer.de";
      };
    };

  modules.nixos.sops =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      cfg = config.services.home-assistant;
    in

    {
      config = mkIf cfg.enable {
        sops.secrets.hass = {
          sopsFile = ./secrets.yaml;
          path = "${cfg.configDir}/secrets.yaml";
          owner = "hass";
          group = "hass";
          mode = "0440";
          restartUnits = [ "home-assistant.service" ];
        };
      };
    };

  modules.nixos.postgresql =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      cfg = config.services.home-assistant;
    in

    {
      config = mkIf cfg.enable {
        services.home-assistant.config.recorder.db_url = "postgresql://@/hass";

        services.postgresql.ensureDatabases = [ "hass" ];
        services.postgresql.ensureUsers = [
          {
            name = "hass";
            ensureDBOwnership = true;
          }
        ];
      };
    };
}
