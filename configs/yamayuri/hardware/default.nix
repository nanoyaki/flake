{ inputs, ... }:

let
  inherit (inputs) nixos-hardware;
in

{
  imports = [
    ./boot.nix
    ./mounts.nix
    ./swap.nix

    nixos-hardware.nixosModules.raspberry-pi-3
  ];

  hardware.enableRedistributableFirmware = true;
}
