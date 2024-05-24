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

  # VR
  # services.monado = {
  #   package = pkgs.monado;
  #   enable = true;
  #   defaultRuntime = true;
  # };

  # boot.kernelPatches = [
  #   {
  #     name = "cap_sys_nice_begone";
  #     patch = builtins.fetchurl {
  #       url = "https://codeberg.org/Scrumplex/flake/raw/commit/3ec4940bb61812d3f9b4341646e8042f83ae1350/pkgs/cap_sys_nice_begone.patch";
  #       sha256 = "07a1e8cb6f9bcf68da3a2654c41911d29bcef98d03fb6da25f92595007594679";
  #     };
  #   }
  # ];

  environment.systemPackages = with pkgs; [
    mongodb
  ];

  services.xserver.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  hardware.amdgpu.amdvlk = false;

  systemd.services.mongod = {
    enable = true;
    name = "mongod.service";
    description = "Mongo Database";
    serviceConfig = {
      ExecStart = "mongod --dbpath /data/db";
      User = "root";
    };
    wantedBy = ["multi-user.target"];
  };
}
