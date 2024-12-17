{
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];

    loader.efi.efiSysMountPoint = "/boot/efi";
    loader.grub = {
      enable = true;
      efiSupport = true;
      useOSProber = true;
      device = "nodev";
      configurationLimit = 10;
    };

    supportedFilesystems = [ "ntfs" ];
  };
}
