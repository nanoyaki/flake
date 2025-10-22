{ inputs, ... }:

let
  inherit (inputs) nixos-hardware;
in

{
  imports = [
    ./boot.nix
    ./swap.nix
    ./mounts.nix

    nixos-hardware.nixosModules.raspberry-pi-3
  ];

  hardware.enableRedistributableFirmware = true;
}
