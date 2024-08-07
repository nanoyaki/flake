# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd" "ryzen_smu" "amdgpu" "it87"];
  boot.kernelParams = ["acpi_enforce_resources=lax"];
  # boot.extraModulePackages = with pkgs; [
  #   linuxKernel.packages.linux_zen.it87
  # ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4bd44a3e-f38f-4e9a-b64c-1e7381b98b1d";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/98B4-F731";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  # FileSystem Mounts
  fileSystems."/mnt/Windows" = {
    device = "/dev/disk/by-uuid/EA24815F24812F9D";
    fsType = "auto";
    options = [
      "x-gvfs-show"
      "x-gvfs-name=Windows"
      "x-gvfs-icon=Windows"
      "x-gvfs-symbolic-icon=Windows"
    ];
  };

  fileSystems."/mnt/1TB-SSD" = {
    device = "/dev/disk/by-uuid/AC14148D14145CA0";
    fsType = "auto";
    options = [
      "x-gvfs-show"
      "x-gvfs-name=1TB-SSD"
      "x-gvfs-icon=1TB-SSD"
      "x-gvfs-symbolic-icon=1TB-SSD"
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024; # 32GB
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # CPU
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.ryzen-smu.enable = true;
  systemd.services.cpu_undervolt = {
    path = [pkgs.python3];
    enable = true;
    name = "cpu_undervolt.service";
    description = "Undervolt Ryzen 7 5800X3D";
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 /home/hana/git-repos/Ryzen-5800x3d-linux-undervolting/ruv.py -c 8 -o -30";
      User = "root";
    };
    wantedBy = ["multi-user.target"];
  };

  # GPU
  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
    gpuOverclock.ppfeaturemask = "0xffffffff";
  };
  security.polkit = {
    enable = true;
    # Corectrl
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.corectrl.helper.init" ||
          action.id == "org.corectrl.helperkiller.init") &&
          subject.local == true &&
          subject.active == true &&
          subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
      });
    '';
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = ["amdgpu"];
  hardware.amdgpu.amdvlk.enable = false;

  hardware.steam-hardware.enable = true;

  hardware.bluetooth.enable = true;

  programs.coolercontrol.enable = true;
}
