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
    ../../nixosModules/vr.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  networking.hostName = "${username}-nixos";

  modules.vr.enableAmdgpuPatch = true;

  environment.systemPackages = with pkgs; [
    protonvpn-gui
    imagemagick
  ];

  services.transmission = {
    enable = true;
    webHome = pkgs.flood-for-transmission;
    settings.download-dir = "/mnt/1TB-SSD/Torrents";
  };
}
