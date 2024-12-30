{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  hardware.nvidia = {
    open = true;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  environment.variables.LIBVA_DRIVER_NAME = "nvidia";
}
