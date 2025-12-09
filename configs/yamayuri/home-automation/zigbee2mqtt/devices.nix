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

    [[ ! -f ${config.services.zigbee2mqtt.dataDir}/devices.yaml ]] && \
      cp -af ${./devices.yaml} ${config.services.zigbee2mqtt.dataDir}/devices.yaml
  '';
}
