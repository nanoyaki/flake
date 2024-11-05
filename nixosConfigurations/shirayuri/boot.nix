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

    loader.grub.useOSProber = true;

    supportedFilesystems = [ "ntfs" ];
  };
}
