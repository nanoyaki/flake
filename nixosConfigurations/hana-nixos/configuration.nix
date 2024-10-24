# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixosModules/gaming.nix
    # ../../nixosModules/vr.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  networking.hostName = "${username}-nixos";

  programs.thunderbird.enable = false;

  # modules.vr.enableAmdgpuPatch = true;

  environment.systemPackages = with pkgs; [
    protonvpn-gui
    headsetcontrol
    xmousepasteblock

    imagemagick
  ];

  services.udev.packages = with pkgs; [
    headsetcontrol
  ];

  programs.firefox.enable = true;

  services.transmission = {
    enable = true;
    webHome = pkgs.flood-for-transmission;
    settings.download-dir = "/mnt/1TB-SSD/Torrents";
  };
}
