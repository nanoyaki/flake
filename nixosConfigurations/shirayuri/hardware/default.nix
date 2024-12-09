{ inputs, ... }:

{
  imports = [
    ./cpu.nix
    ./gpu.nix
    ./boot.nix
    ./mounts.nix
    ./swap.nix
    ./cooling.nix
    ./scarlett-solo.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware = {
    enableRedistributableFirmware = true;

    steam-hardware.enable = true;

    bluetooth.enable = true;
  };
}
