{ inputs, ... }:

{
  flake.nixosModules.kuroyuri-gpu = {
    imports = [ inputs.nixos-hardware.nixosModules.common-gpu-amd ];

    boot.kernelModules = [ "amdgpu" ];

    hardware = {
      amdgpu.initrd.enable = true;

      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    environment.sessionVariables.VDPAU_DRIVER = "radeonsi";
    services.xserver.videoDrivers = [ "amdgpu" ];
  };
}
