{ config, ... }:

{
  hardware.graphics.enable = true;

  nixpkgs.config.nvidia.acceptLicense = true;

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

    nvidiaSettings = true;
    modesetting.enable = true;
    powerManagement = {
      enable = false;
      finegrained = false;
    };

    prime.nvidiaBusId = "PCI:1:0:0";
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidiaLegacy470" ];
  };
}
