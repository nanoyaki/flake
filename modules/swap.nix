{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.swap ];
  };

  modules.nixos.swap = {
    swapDevices = [
      {
        device = "/var/swap";
        size = 8 * 1024;
      }
    ];

    zramSwap.enable = true;
  };
}
