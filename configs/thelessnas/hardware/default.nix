{ inputs, ... }:

{
  imports = [
    ./mounts.nix
    ./boot.nix
    ./swap.nix
    ./cpu.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];
}
