{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./boot.nix
    ./cpu.nix
    ./swap.nix
  ];
}
