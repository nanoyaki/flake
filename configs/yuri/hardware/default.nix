{ inputs, ... }:

let
  inherit (inputs) disko nixos-hardware;
in

{
  imports = [
    disko.nixosModules.disko
    ./disks.nix
    ./boot.nix
    ./cpu.nix
    ./swap.nix

    nixos-hardware.nixosModules.common-pc-ssd
  ];
}
