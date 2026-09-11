{ inputs, ... }:

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
    imports = [ inputs.disko.nixosModules.disko ];

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
}
