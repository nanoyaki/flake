{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/6b0f9b6a-1931-46a9-a0a7-9914d65ae2b8";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/98B4-F731";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    # FileSystem Mounts
    "/mnt/Windows" = {
      device = "/dev/disk/by-uuid/EA24815F24812F9D";
      fsType = "auto";
      options = [
        "x-gvfs-show"
        "x-gvfs-name=Windows"
        "x-gvfs-icon=Windows"
        "x-gvfs-symbolic-icon=Windows"
      ];
    };

    "/mnt/1TB-SSD" = {
      device = "/dev/disk/by-uuid/AC14148D14145CA0";
      fsType = "auto";
      options = [
        "x-gvfs-show"
        "x-gvfs-name=1TB-SSD"
        "x-gvfs-icon=1TB-SSD"
        "x-gvfs-symbolic-icon=1TB-SSD"
      ];
    };
  };
}
