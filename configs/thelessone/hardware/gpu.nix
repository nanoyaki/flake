{ pkgs, config, ... }:

{
  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  nixpkgs.config.nvidia.acceptLicense = true;

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;

    prime = {
      reverseSync.enable = true;

      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:10:0:0";
    };

    modesetting.enable = true;
    powerManagement = {
      enable = false;
      finegrained = false;
    };
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";
  };
  environment.systemPackages = [ pkgs.cudaPackages.cudatoolkit ];

  services.no-rgb.enable = true;
}
