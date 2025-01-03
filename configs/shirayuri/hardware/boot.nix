{ lib, ... }:

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

    loader = {
      efi.efiSysMountPoint = "/boot";

      systemd-boot = {
        enable = lib.mkForce false;
        configurationLimit = 30;
      };

      timeout = 0;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    supportedFilesystems = [ "ntfs" ];
  };
}
