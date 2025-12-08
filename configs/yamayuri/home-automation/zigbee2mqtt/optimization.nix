{ lib, ... }:

{
  # Due to memory limitations, we have to save
  # memory where possible. The frontend uses
  # up to 70mb **when idle** from the available
  # 900mb or so
  services.zigbee2mqtt.settings.frontend.enabled = lib.mkDefault false;

  # Add specilisation to enable frontend when required
  specialisation.z2m-frontend.configuration.services.zigbee2mqtt.settings.frontend.enabled = true;
}
