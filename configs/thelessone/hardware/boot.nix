{ config, ... }:

{
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/nvme0n1";
    };

    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];

    kernelParams = [
      "acpi_enforce_resources=lax"
    ];

    kernelModules = [
      "kvm-intel"
      "it87"
      "r8125"
    ];

    extraModulePackages = [
      config.boot.kernelPackages.it87
      config.boot.kernelPackages.r8125
    ];
    extraModprobeConfig = ''
      options it87 force_id=0x8628
    '';
  };
}
