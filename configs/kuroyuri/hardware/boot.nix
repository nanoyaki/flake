{ lib, inputs, ... }:

{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  nix.settings.trusted-substituters = [ "https://lanzaboote.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
  ];

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
