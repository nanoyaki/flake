{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices.disk.nixos = {
    device = "/dev/nvme0n1";
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
            mountOptions = [ "compress=zstd" ];
            extraArgs = [ "-f" ];
          };
        };
      };
    };
  };
}
