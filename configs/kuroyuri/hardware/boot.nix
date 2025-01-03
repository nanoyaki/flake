{
  lib,
  ...
}:

{
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
    ];

    loader = {
      efi.efiSysMountPoint = "/boot";
      systemd-boot.enable = lib.mkForce false;
      timeout = 0;
    };

    # replaces systemd-boot
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
