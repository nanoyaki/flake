{ config, ... }:

{
  sops.secrets.hass = {
    path = "${config.services.home-assistant.configDir}/secrets.yaml";
    owner = "hass";
    group = "hass";
    mode = "0440";
    restartUnits = [ "home-assistant.service" ];
  };
}
