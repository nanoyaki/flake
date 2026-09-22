{ config, ... }:

{
  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.ntsync ];
  };

  modules.nixos.ntsync = {
    boot.kernelModules = [ "ntsync" ];
  };
}
