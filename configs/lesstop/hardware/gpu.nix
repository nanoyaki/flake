{ pkgs, config, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.variables.LIBVA_DRIVER_NAME = "nvidia";
  environment.systemPackages = [
    pkgs.cudaPackages_12_4.cudatoolkit
  ];
}
