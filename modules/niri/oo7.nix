{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.oo7 ];
  };

  modules.nixos.oo7 = {
    services.oo7.enable = true;
  };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.oo7 ];
  };

  # Mainly configured in the niri config
  modules.home.oo7 = { };
}
