# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../common/modules/x3d-undervolt.nix
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [
    "it87"
  ];

  boot.kernelModules = [
    "kvm-amd"
    "ryzen_smu"
    "amdgpu"
    "it87"
  ];

  boot.kernelParams = [ "acpi_enforce_resources=lax" ];

  boot.extraModulePackages = with pkgs; [
    linuxKernel.packages.linux_zen.it87
  ];

  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8211 device_setup=1
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4bd44a3e-f38f-4e9a-b64c-1e7381b98b1d";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/98B4-F731";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
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

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
    gpuOverclock.ppfeaturemask = "0xffffffff";
  };

  security.polkit = {
    enable = true;
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

  services.x3d-undervolt = {
    enable = true;
    cores = 8;
    milivolts = 30;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.amdgpu.amdvlk.enable = false;

  hardware.amdgpu.initrd.enable = true;

  hardware.steam-hardware.enable = true;

  hardware.bluetooth.enable = true;

  programs.coolercontrol.enable = true;
}
