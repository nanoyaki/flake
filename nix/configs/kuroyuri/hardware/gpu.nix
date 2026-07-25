{ inputs, ... }:

{
  flake.nixosModules.kuroyuri-gpu = {
    imports = [ inputs.nixos-hardware.nixosModules.common-gpu-amd ];
    services.xserver.videoDrivers = [ "amdgpu" ];
    boot.kernelModules = [ "amdgpu" ];
    environment.sessionVariables.VDPAU_DRIVER = "radeonsi";

    hardware = {
      amdgpu.initrd.enable = true;

      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}
