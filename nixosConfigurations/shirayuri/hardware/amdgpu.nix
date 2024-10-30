{ ... }:
{
  hardware.amdgpu.initrd.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.variables.VDPAU_DRIVER = "radeonsi";
  hardware.amdgpu.amdvlk.enable = false;

  services.xserver.videoDrivers = [ "amdgpu" ];
}
