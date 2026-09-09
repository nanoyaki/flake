{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.mosquitto ];
  };

  modules.nixos.mosquitto = {
    services.mosquitto.enable = true;
    services.mosquitto.listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };
}
