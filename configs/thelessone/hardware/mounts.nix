{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/711ead47-e4f7-4ef4-b7bf-daac6220243a";
    fsType = "ext4";
  };

  fileSystems."/mnt/raid" = {
    device = "/dev/disk/by-uuid/a707cee3-3b90-4b19-9b4b-7f0f3454e49c";
    fsType = "btrfs";
    options = [
      "defaults"
      "compress=zstd"
      "space_cache=v2"
    ];
  };

  fileSystems."/mnt/nas" = {
    device = "//192.168.178.91/public";
    fsType = "cifs";
    options = [
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "uid=1000"
      "gid=100"
    ];
  };
}
