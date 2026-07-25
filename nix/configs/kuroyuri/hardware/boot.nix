{
  flake.nixosModules.kuroyuri-boot =
    {
      lib,
      pkgs,
      ...
    }:

    {
      boot.initrd.availableKernelModules = [
        "nvme"
        "sd_mod"
        "usb_storage"
        "xhci_pci"
      ];

      boot.kernelPackages = pkgs.linuxPackages_zen;

      boot.loader = {
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/boot";

        limine = {
          enable = true;
          secureBoot.enable = true;
        };

        systemd-boot.enable = lib.mkForce false;
        timeout = 0;
      };

      hardware.bluetooth.enable = true;
    };
}
