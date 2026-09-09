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
}
