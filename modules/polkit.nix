{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.polkit ];
  };

  modules.nixos.polkit = {
    security.polkit.enable = true;
    security.polkit.enablePkexecWrapper = true;
  };
}
