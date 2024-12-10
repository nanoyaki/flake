{ inputs, ... }:

let
  inherit (inputs) nixos-hardware;
in

{
  imports = [
    ./cpu.nix
    ./gpu.nix
    ./boot.nix
    ./mounts.nix
    ./swap.nix

    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-cpu-amd-pstate
    nixos-hardware.nixosModules.common-cpu-amd-zenpower
    nixos-hardware.nixosModules.common-gpu-amd
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  hardware.enableRedistributableFirmware = true;

  services.libinput.touchpad.naturalScrolling = true;
}
