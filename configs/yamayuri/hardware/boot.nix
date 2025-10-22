{ pkgs, ... }:

{
  boot.kernelParams = [
    "console=ttyS1,115200n8"
  ];

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;
}
