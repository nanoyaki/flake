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
    kernelModules = [
      "kvm-amd"
      "it87"
    ];
    kernelParams = [
      "amdgpu.dc=0"
      "amdgpu.modeset=0"
    ];
    blacklistedKernelModules = [ "amdgpu" ];

    extraModulePackages = [ config.boot.kernelPackages.it87 ];
    extraModprobeConfig = ''
      options it87 force_id=0x8686 ignore_resource_conflict=1
    '';

    loader.systemd-boot.enable = true;
  };

  specialisation.graphical.configuration.boot = {
    blacklistedKernelModules = lib.mkForce (
      lib.filter (module: module != "amdgpu") config.boot.blacklistedKernelModules
    );
    kernelParams = lib.mkForce (
      lib.filter (param: param != "amdgpu.dc=0" && param != "amdgpu.modeset=0") config.boot.kernelParams
    );
  };
}
