{
  boot = {
    initrd = {
      availableKernelModules = [
        "vmd"
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };
}
