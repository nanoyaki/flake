{ inputs, ... }:

let
  inherit (inputs) nixos-hardware;
in

{
  imports = [
    ./boot.nix
    ./disks.nix
    ./gpu.nix

    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-gpu-nvidia
    nixos-hardware.nixosModules.common-cpu-intel-cpu-only
  ];

  hardware.enableRedistributableFirmware = true;
}
