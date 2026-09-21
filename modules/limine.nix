{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.limine ];

    boot.loader.limine.secureBoot.enable = true;
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.limine ];

    boot.loader.limine.secureBoot.enable = true;
    boot.loader.limine.extraEntries = ''
      /Windows
        protocol: efi
        path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };

  modules.nixos.limine = {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.limine.enable = true;
  };
}
