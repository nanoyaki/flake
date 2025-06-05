{ lib, config, ... }:

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
    blacklistedKernelModules = [ "i915" ];
    kernelParams = [ "i915.modeset=0" ];

    loader.systemd-boot.enable = true;
  };

  specialisation.graphical.configuration.boot = {
    blacklistedKernelModules = lib.mkForce (
      lib.filter (param: param != "i915") config.boot.blacklistedKernelModules
    );
    kernelParams = lib.mkForce (lib.filter (param: param != "i915.modeset=0") config.boot.kernelParams);
  };
}
