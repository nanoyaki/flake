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

    mode = "600";
    owner = "zigbee2mqtt";
    group = "zigbee2mqtt";

    path = "${config.services.zigbee2mqtt.dataDir}/configuration.yaml";
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant.enabled = config.services.home-assistant.enable;
      permit_join = true;

      serial.port = "/dev/serial/by-id/usb-dresden_elektronik_ingenieurtechnik_GmbH_ConBee_II_DE2706266-if00";
      serial.adapter = "deconz";

      frontend.enabled = true;
      frontend.port = 9831;

      advanced.channel = 25;
      advanced.cache_state = true;
    };
  };

  systemd.services.zigbee2mqtt.preStart = lib.mkForce ''echo "Skip copying settings file, we use sops-nix here"'';

  services.caddy.virtualHosts."z2m.hanakretzer.de" = {
    listenAddresses = [
      "127.0.0.1"
      "::1"
      "10.101.0.1"
      "fd10::1"
      "10.0.0.3"
    ];

    useACMEHost = "hanakretzer.de";
    extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.zigbee2mqtt.settings.frontend.port}
    '';
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };
}
