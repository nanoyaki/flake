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

    inputs.aagl.nixosModules.default

    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # Networking
  networking.hostName = "${username}-nixos";

  # VR
  # TODO: put this in some module
  # services.monado = {
  #   package = pkgs.monado;
  #   enable = true;
  #   defaultRuntime = true;
  # };

  # VR Patch
  boot.kernelPatches = [
    {
      name = "cap_sys_nice_begone";
      patch = builtins.fetchurl {
        url = "https://codeberg.org/Scrumplex/flake/raw/commit/3ec4940bb61812d3f9b4341646e8042f83ae1350/pkgs/cap_sys_nice_begone.patch";
        sha256 = "07a1e8cb6f9bcf68da3a2654c41911d29bcef98d03fb6da25f92595007594679";
      };
    }
  ];

  environment.systemPackages = with pkgs;
    [
      # Programming
      libgcc
      gcc
      gnumake

      # Games
      mangohud

      # Image manipulation
      imagemagick
      gimp

      # VR
      unityhub
      vrc-get
      pavucontrol
      index_camera_passthrough
      opencomposite-helper
      wlx-overlay-s
      lighthouse-steamvr

      # OS
      usbutils
    ]
    ++ [
      inputs.envision.packages."x86_64-linux".envision
    ];

  environment.variables = {
    PKG_CONFIG_PATH = "/run/current-system/sw/bin/openssl";
  };

  nix.settings = inputs.aagl.nixConfig; # Set up Cachix

  programs = {
    anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
    honkers-railway-launcher.enable = true;

    steam.extraPackages = with pkgs; [
      gamescope
    ];

    coolercontrol.enable = true;
  };

  services.xserver.enable = true;
}
