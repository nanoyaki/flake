{
  imports = [
    ./mounts.nix
    ./swap.nix
    ./cpu.nix
    ./boot.nix
    ./gpu.nix
    ./mainboard.nix
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
}
