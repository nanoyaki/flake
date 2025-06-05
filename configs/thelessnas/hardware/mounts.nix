{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/732c4fe7-e780-408f-94f1-70e919db209e";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A69C-9FBB";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
}
