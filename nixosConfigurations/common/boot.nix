{ lib, pkgs, ... }:

{
  time.hardwareClockInLocalTime = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    loader = {
      efi = {
        canTouchEfiVariables = lib.mkDefault true;
        efiSysMountPoint = lib.mkDefault "/boot/efi";
      };

      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        configurationLimit = lib.mkDefault 10;
      };
    };

    plymouth.enable = true;
  };
}
