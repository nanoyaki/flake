{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.zigbee2mqtt ];
  };

  modules.nixos.zigbee2mqtt =
    { lib, config, ... }:

    let
      cfg = config.services.zigbee2mqtt;
    in

    {
      assertions = [
        {
          assertion = config.services.mosquitto.enable;
          message = ''
            The MQTT broker Mosquitto must be enabled.
          '';
        }
      ];

      systemd.services.zigbee2mqtt.preStart = lib.mkForce ''
        # This also skips copying the settings file
        # since we use sops-nix for that

        install -Dm644 ${./devices.yaml} "${cfg.dataDir}/devices.yaml"
      '';

      services.zigbee2mqtt.enable = true;
      services.zigbee2mqtt.settings = {
        devices = "devices.yaml";
        homeassistant.enabled = config.services.home-assistant.enable;
        permit_join = true;

        serial.port = "/dev/serial/by-id/usb-dresden_elektronik_ingenieurtechnik_GmbH_ConBee_II_DE2706266-if00";
        serial.adapter = "deconz";

        frontend.port = 9831;
        frontend.enabled = true;

        advanced.channel = 25;
        advanced.cache_state = true;
      };

      networking.firewall.allowedTCPPorts = [
        (cfg.settings.frontend.port or 9831)
      ];
    };

  modules.nixos.caddy =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      cfg = config.services.zigbee2mqtt;
    in

    {
      config = mkIf cfg.enable {
        services.caddy.virtualHosts."z2m.hanakretzer.de".extraConfig = ''
          reverse_proxy [::1]:${toString cfg.settings.frontend.port}
        '';
      };
    };

  modules.nixos.tailscale =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      cfg = config.services.zigbee2mqtt;
    in

    {
      config = mkIf (cfg.enable && config.services.caddy.enable) {
        services.caddy.virtualHosts."z2m.hanakretzer.de".tailnetOnly = true;
      };
    };

  modules.nixos.acme =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      cfg = config.services.zigbee2mqtt;
    in

    {
      config = mkIf (cfg.enable && config.services.caddy.enable) {
        services.caddy.virtualHosts."z2m.hanakretzer.de".useACMEHost = "hanakretzer.de";
      };
    };

  modules.nixos.sops =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib)
        mkIf
        mkOverride
        recursiveUpdate
        ;

      cfg = config.services.zigbee2mqtt;
      format = pkgs.formats.yaml { };
    in

    {
      config = mkIf cfg.enable {
        sops.secrets = {
          network_key.sopsFile = ./secrets.yaml;
          pan_id.sopsFile = ./secrets.yaml;
          ext_pan_id.sopsFile = ./secrets.yaml;
        };

        sops.templates."configuration.yaml" = {
          file = format.generate "configuration.yaml.template" (
            recursiveUpdate {
              advanced = {
                inherit (config.sops.placeholder)
                  network_key
                  pan_id
                  ext_pan_id
                  ;
              };
            } cfg.settings
          );
          path = "${cfg.dataDir}/configuration.yaml";
          mode = "600";
          owner = "zigbee2mqtt";
          group = "zigbee2mqtt";
          restartUnits = [ "zigbee2mqtt.service" ];
        };

        systemd.services.zigbee2mqtt.preStart = mkOverride 100 ''
          echo "Skipping configuration copy."
        '';
      };
    };

  modules.nixos.rustic =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      cfg = config.services.zigbee2mqtt;
    in

    {
      config = mkIf cfg.enable {
        services.rustic.backups.zigbee2mqtt = {
          paths = [ cfg.dataDir ];
          exclude = [ "${cfg.dataDir}/configuration.yaml" ];
        };
      };
    };
}
