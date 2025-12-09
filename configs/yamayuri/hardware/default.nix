{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (inputs) nixos-hardware;
in

{
  imports = [
    ./swap.nix

    nixos-hardware.nixosModules.raspberry-pi-3
  ];

  boot.initrd.supportedFilesystems.zfs = lib.mkForce false;
  boot.supportedFilesystems.zfs = lib.mkForce false;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;

  hardware.enableRedistributableFirmware = true;

  # Disk optimization
  fileSystems."/".options = [ "noatime" ];
}
