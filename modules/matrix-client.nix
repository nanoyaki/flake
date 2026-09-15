{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.matrix-client ];
  };

  modules.nixos.matrix-client =
    { pkgs, ... }:

    {
      environment.systemPackages = [ pkgs.fluffychat ];
    };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.matrix-client ];
  };

  modules.home.matrix-client =
    { pkgs, ... }:

    {
      home.packages = [ pkgs.fluffychat ];
    };
}
