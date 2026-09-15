{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.signal ];
  };

  modules.nixos.signal =
  { pkgs, ... }:

  {
    environment.systemPackages = [ pkgs.signal-desktop ];
  };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.signal ];
  };

  modules.home.signal =
  { pkgs, ... }:

  {
    home.packages = [ pkgs.signal-desktop ];
  };
}
