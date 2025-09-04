{ pkgs, ... }:

{
  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;
}
