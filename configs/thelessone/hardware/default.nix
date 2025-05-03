{ inputs, ... }:

{
  imports = [
    ./gpu.nix
    ./boot.nix
    ./mounts.nix
    ./swap.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.enableRedistributableFirmware = true;
}
