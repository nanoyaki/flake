{ inputs, ... }:

{
  imports = [
    ./cpu.nix
    ./gpu.nix
    ./boot.nix
    ./mounts.nix
    ./swap.nix

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.enableRedistributableFirmware = true;
}
