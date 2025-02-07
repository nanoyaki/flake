{
  boot = {
    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sr_mod"
    ];
    kernelModules = [ "kvm-intel" ];

    loader.systemd-boot.enable = true;
  };
}
