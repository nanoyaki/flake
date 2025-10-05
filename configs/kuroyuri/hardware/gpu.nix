{
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
}
