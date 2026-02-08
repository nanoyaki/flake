{ inputs, ... }:

{
  flake.nixosModules.shirayuri-disks = {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.nixos = {
      device = "/dev/disk/by-id/nvme-CT1000P1SSD8_2030E2BAC10A";
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

    fileSystems."/mnt/os-shared" = {
      device = "/dev/disk/by-uuid/71f7fad7-7dcb-4aef-ab9a-5e9499215156";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "uid=1000"
        "gid=100"
      ];
    };

    services.gvfs.enable = true;
    services.udisks2.enable = true;
  };
}
