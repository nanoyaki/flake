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
        "xhci_pci"
        "usb_storage"
        "sd_mod"
      ];

      boot.loader = {
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/boot";
        systemd-boot.enable = lib.mkForce false;
        timeout = 0;

        limine = {
          enable = true;
          secureBoot.enable = true;
        };
      };

      boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
    };
}
