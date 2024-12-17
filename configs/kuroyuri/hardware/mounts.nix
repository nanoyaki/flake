{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/9c24b591-d0b1-4d31-9a5a-51b9df0cf775";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/746D-88D6";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
