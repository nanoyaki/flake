{
  imports = [
    ./boot.nix
    ./mounts.nix
    ./swap.nix
  ];

  hardware.enableRedistributableFirmware = true;
}
