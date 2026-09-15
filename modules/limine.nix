{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.limine ];

    boot.loader.limine.secureBoot.enable = true;
  };

  modules.nixos.limine = {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.limine.enable = true;
  };
}
