{ ... }:

{
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
    ];

    loader = {
      efi.canTouchEfiVariables = false;
      grub.efiInstallAsRemovable = true;
    };
  };
}
