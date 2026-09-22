{ config, ... }:

{
  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.signal ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.signal ];
  };

  modules.home.signal =
    { pkgs, ... }:

    {
      home.packages = [ pkgs.signal-desktop ];
    };
}
