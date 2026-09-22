{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.power-profiles-daemon ];
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.power-profiles-daemon ];
  };

  modules.nixos.power-profiles-daemon = {
    services.power-profiles-daemon.enable = true;
  };
}
