{
  disko.devices.disk.hardDrive0 = {
    device = "/dev/sda";
    type = "disk";

    content = {
      type = "gpt";

      partitions = {
        esp = {
          name = "ESP";
          priority = 1;
          type = "EF00";
          end = "500M";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        root = {
          name = "root";
          size = "100%";

          content = {
            type = "btrfs";
            mountpoint = "/";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
            extraArgs = [ "-f" ]; # Override existing partition
          };
        };
      };
    };
  };
}
