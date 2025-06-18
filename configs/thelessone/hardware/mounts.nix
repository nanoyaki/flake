{
  boot.supportedFilesystems.nfs = true;

  fileSystems."/mnt/raid" = {
    device = "192.168.178.91:/moon";
    fsType = "nfs";
    options = [ "nfsvers=4.2" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/711ead47-e4f7-4ef4-b7bf-daac6220243a";
    fsType = "ext4";
  };
}
