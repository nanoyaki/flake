{
  boot.kernelModules = [ "amdgpu" ];

  hardware = {
    amdgpu = {
      initrd.enable = true;
      amdvlk.enable = false;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  environment.sessionVariables.VDPAU_DRIVER = "radeonsi";
  services.xserver.videoDrivers = [ "amdgpu" ];
}
