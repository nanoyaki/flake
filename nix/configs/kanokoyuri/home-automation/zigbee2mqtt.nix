{
  flake.nixosModules.kanokoyuri-zigbee2mqtt =
    {
      lib,
      config,
      pkgs,
      ...
    }:

    {
      sops.secrets = {
        "zigbee2mqtt/network_key" = { };
        "zigbee2mqtt/pan_id" = { };
        "zigbee2mqtt/ext_pan_id" = { };
      };

      sops.templates."configuration.yaml" = {
        file = (pkgs.formats.yaml { }).generate "configuration.yaml.template" (
          lib.recursiveUpdate {
            advanced = {
              network_key = config.sops.placeholder."zigbee2mqtt/network_key";
              pan_id = config.sops.placeholder."zigbee2mqtt/pan_id";
              ext_pan_id = config.sops.placeholder."zigbee2mqtt/ext_pan_id";
            };
          } config.services.zigbee2mqtt.settings
        );
        path = "${config.services.zigbee2mqtt.dataDir}/configuration.yaml";
        mode = "600";
        owner = "zigbee2mqtt";
        group = "zigbee2mqtt";
        restartUnits = [ "zigbee2mqtt.service" ];
      };

      systemd.services.zigbee2mqtt.preStart = lib.mkForce ''
        # This also skips copying the settings file
        # since we use sops-nix for that

        install -Dm644 ${./devices.yaml} "${config.services.zigbee2mqtt.dataDir}/devices.yaml"
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

      services.caddy.virtualHosts."z2m.hanakretzer.de" = {
        listenAddresses = [
          "127.0.0.1"
          "::1"
          "10.101.0.1"
          "fd10::1"
          "10.0.0.9"
        ];

        useACMEHost = "hanakretzer.de";
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.zigbee2mqtt.settings.frontend.port}
        '';
      };

      services.mosquitto.enable = true;
      services.mosquitto.listeners = [
        {
          acl = [ "pattern readwrite #" ];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];

      networking.firewall.allowedTCPPorts = [
        (config.services.zigbee2mqtt.settings.frontend.port or 9831)
      ];
    };
}
