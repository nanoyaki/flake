{ inputs, ... }:

{
  flake.nixosModules.kuroyuri-gpu = {
    imports = [ inputs.nixos-hardware.nixosModules.common-gpu-amd ];

    hardware = {
      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
        zluda.enable = true;
      };

      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    boot.kernelModules = [ "amdgpu" ];
    environment.sessionVariables.VDPAU_DRIVER = "radeonsi";
    services.xserver.videoDrivers = [ "amdgpu" ];
  };
}
