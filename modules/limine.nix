{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.limine ];
  };

  modules.nixos.limine = {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.limine.enable = true;
  };
}
