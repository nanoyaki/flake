# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../common/modules/gaming.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # Networking
  networking.hostName = "${username}-nixos";

  programs.thunderbird.enable = false;

  modules.gaming.enable = true;

  services.suwayomi-server = {
    enable = true;
    settings.server.port = 4567;
  };

  environment.systemPackages = with pkgs; [
    protonvpn-gui
  ];
}
