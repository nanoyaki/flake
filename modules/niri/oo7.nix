{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.oo7 ];
  };

  modules.nixos.oo7 = {
    services.oo7.enable = true;
  };
}
