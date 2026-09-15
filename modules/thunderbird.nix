{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.thunderbird ];
  };

  modules.nixos.thunderbird = {
    programs.thunderbird.enable = true;
  };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.thunderbird ];
  };

  modules.home.thunderbird = {
    programs.thunderbird.enable = true;
  };
}
