{ inputs, ... }:

{
  flake.nixosModules.kuroyuri-drives = {
    imports = with inputs.nixos-hardware.nixosModules; [
      common-pc-laptop
      common-pc-laptop-ssd
    ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/9c24b591-d0b1-4d31-9a5a-51b9df0cf775";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      options = [
        "dmask=0022"
        "fmask=0022"
      ];

      device = "/dev/disk/by-uuid/746D-88D6";
      fsType = "vfat";
    };

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 16 * 1024; # 16GB
      }
    ];

    zramSwap.enable = true;
  };
}
