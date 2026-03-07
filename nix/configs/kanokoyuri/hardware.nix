{
  flake.nixosModules.kanokoyuri-hardware =
    {
      lib,
      pkgs,
      ...
    }:

    {
      boot.initrd.supportedFilesystems.zfs = lib.mkForce false;
      boot.supportedFilesystems.zfs = lib.mkForce false;
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.loader = {
        efi.efiSysMountPoint = "/boot";
        systemd-boot.enable = true;
        timeout = 3;
      };

      hardware.enableRedistributableFirmware = true;

      # Disk optimization
      fileSystems."/".options = [ "noatime" ];

      swapDevices = [
        {
          device = "/var/swap";
          size = 8 * 1024;
        }
      ];

      zramSwap.enable = true;
    };
}
