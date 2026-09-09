{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.systemd-boot ];
  };

  modules.nixos.systemd-boot = {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = true;
  };
}
