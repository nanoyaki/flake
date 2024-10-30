{ inputs, ... }:

{
  imports = [
    ./cpu.nix
    ./amdgpu.nix
    ./mounts.nix
    ./cooling.nix
    ./scarlett-solo.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.enableRedistributableFirmware = true;

  hardware.steam-hardware.enable = true;

  hardware.bluetooth.enable = true;
}
