{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.linux ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.linux ];
  };

  modules.nixos.linux =
    { pkgs, ... }:

    {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
}
