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

  # Networking
  networking.hostName = "${username}-nixos";

  environment.systemPackages = with pkgs; [
    # Programming
    libgcc
    gcc

    # Games
    mangohud

    # Email
    thunderbird-bin
  ];

  # Steam config taken from:
  # https://codeberg.org/Scrumplex/flake/src/commit/38473f45c933e3ca98f84d2043692bb062807492/nixosConfigurations/common/desktop/gaming.nix#L20-L35
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    extraPackages = with pkgs; [gamescope];
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  services.transmission = {
    enable = false;
    webHome = pkgs.flood-for-transmission;
  };
}
