{ inputs, config, ... }:

{
  flake-file.inputs.disko.url = "github:nix-community/disko";

  configurations.nixos.kanokoyuri = {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.main = {
      device = "/dev/sda";
      type = "disk";

      content = {
        type = "gpt";

        partitions.ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        partitions.root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  configurations.nixos.himawari = {
    imports = [
      config.modules.nixos.disks
      inputs.disko.nixosModules.disko
    ];

    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Micron_MTFDKCD1T0QFM-1BD1AABLA_23484542AA11";

      content.type = "gpt";
      content.partitions = {
        ESP = {
          type = "EF00";
          size = "1G";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        luks.size = "100%";
        luks.content = {
          type = "luks";
          name = "crypted";
          settings.allowDiscards = true;
          enrollFido2 = true;
          # Do not wait for recovery displaying and blocking formatting.
          enrollRecovery = false;
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.disks ];

    warnings = [
      "migrate to disko with LUKS encryption."
    ];

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/27D0-0225";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/6c7d866a-7754-4eb7-8ea5-cea6f715d8ef";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };

    fileSystems."/mnt/os-shared" = {
      device = "/dev/disk/by-uuid/71f7fad7-7dcb-4aef-ab9a-5e9499215156";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "nofail"
      ];
    };
  };

  modules.nixos.disks = {
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    services.fstrim.enable = true;
  };
}
