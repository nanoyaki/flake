{ config, ... }:

{
  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.matrix-client ];
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.matrix-client ];
  };

  modules.home.matrix-client =
    { pkgs, ... }:

    {
      home.packages = [ pkgs.fluffychat ];
    };
}
