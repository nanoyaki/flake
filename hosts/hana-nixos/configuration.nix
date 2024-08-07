# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../common/modules/gaming.nix
    ../../common/modules/php.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # Networking
  networking.hostName = "${username}-nixos";

  programs.thunderbird.enable = true;

  services.nano.gaming.enable = true;
  services.nano.php.enable = true;
}
