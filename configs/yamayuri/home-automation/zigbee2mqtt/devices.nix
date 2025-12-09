{
  lib,
  config,
  ...
}:

{
  services.zigbee2mqtt.settings.devices = "devices.yaml";

  systemd.services.zigbee2mqtt.preStart = lib.mkForce ''
    # This also skips copying the settings file
    # since we use sops-nix for that

    install -Dm644 ${./devices.yaml} "${config.services.zigbee2mqtt.dataDir}/devices.yaml"
  '';
}
