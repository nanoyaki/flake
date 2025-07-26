{ config, ... }:

{
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];

    kernelModules = [
      "kvm-amd"
      "r8125"
    ];
    extraModulePackages = [ config.boot.kernelPackages.r8125 ];

    loader.systemd-boot.enable = true;
  };
}
