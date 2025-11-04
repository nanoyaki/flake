{ inputs, pkgs, ... }:

let
  inherit (inputs) nixos-hardware;
in

{
  imports = [
    ./swap.nix

    nixos-hardware.nixosModules.raspberry-pi-3
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;

  hardware.enableRedistributableFirmware = true;
}
