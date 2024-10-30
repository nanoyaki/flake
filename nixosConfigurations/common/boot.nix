{ lib, pkgs, ... }:

{
  time.hardwareClockInLocalTime = true;

  boot = {
    loader.efi = {
      canTouchEfiVariables = lib.mkDefault true;
      efiSysMountPoint = lib.mkDefault "/boot/efi";
    };

    loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      configurationLimit = lib.mkDefault 10;
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };
}
