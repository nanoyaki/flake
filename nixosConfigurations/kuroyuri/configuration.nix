{
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub.efiInstallAsRemovable = true;
  };

  networking.hostName = "kuroyuri";
}
