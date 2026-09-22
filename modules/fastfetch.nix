{ config, ... }:

{
  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.fastfetch ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.fastfetch ];
  };

  modules.home.fastfetch = {
    programs.fastfetch.enable = true;
  };
}
