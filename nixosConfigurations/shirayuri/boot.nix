{ ... }:
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

    loader.grub = {
      configurationLimit = 10;
      useOSProber = true;
    };

    supportedFilesystems = [ "ntfs" ];
  };
}
