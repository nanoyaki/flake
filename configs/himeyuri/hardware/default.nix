{
  imports = [
    ./mounts.nix
    ./swap.nix
    ./cpu.nix
    ./boot.nix
    ./gpu.nix
  ];

  hardware.enableRedistributableFirmware = true;
}
