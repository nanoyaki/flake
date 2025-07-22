{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
  ];

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
    options = [ "compress=zstd" ];
  };

  sops.secrets.cifsPassword = { };
  sops.templates.cifs-credentials.file = (pkgs.formats.keyValue { }).generate "cifs-credentials" {
    username = "hana";
    password = config.sops.placeholder."cifsPassword";
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
      "credentials=${config.sops.templates.cifs-credentials.path}"
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
