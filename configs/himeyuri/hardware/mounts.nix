{
  fileSystems = {
    "/" = {
      device = "/dev/nvme0n1p2";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/nvme0n1p1";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };
}
