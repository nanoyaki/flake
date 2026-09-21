{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.swap ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.swap ];
  };

  modules.nixos.swap =
    { lib, ... }:

    let
      inherit (lib) mkDefault;
    in

    {
      swapDevices = [
        {
          device = "/var/swap";
          size = 8 * 1024;
        }
      ];

      zramSwap.enable = mkDefault true;
    };
}
