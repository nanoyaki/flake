{ inputs, config, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  sec.cifsCredentials = { };

  disko.devices.disk = {
    nixos = {
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

    os-shared = {
      device = "/dev/nvme1n1";
      type = "disk";

      content = {
        type = "gpt";

        partitions.main = {
          name = "main";
          size = "100%";

          content = {
            type = "btrfs";
            mountpoint = "/mnt/os-shared";
            mountOptions = [ "compress=zstd" ];
            extraArgs = [ "-f" ];
          };
        };
      };
    };
  };

  fileSystems."/mnt/yuri/hana" = {
    device = "//10.0.0.3/hana";
    fsType = "cifs";
    options = [
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "credentials=${config.sec.cifsCredentials.path}"
      "uid=1000"
      "gid=100"
    ];
  };

  fileSystems."/mnt/yuri/public" = {
    device = "//10.0.0.3/public";
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
