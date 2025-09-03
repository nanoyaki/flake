{
  imports = [
    ./boot.nix
    ./mounts.nix
  ];

  hardware.enableRedistributableFirmware = true;
}
