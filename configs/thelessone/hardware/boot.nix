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

    kernelModules = [ "kvm-intel" ];
  };
}
