# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # Boot settings
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = false;
      };
      grub = {
        efiInstallAsRemovable = true;
      };
    };
  };

  # Networking
  networking.hostName = "${username}-nixos-laptop";

  # Virtualisation
  virtualisation.virtualbox.host.enable = true;
  users.users.${username}.extraGroups = ["vboxusers"];
}
