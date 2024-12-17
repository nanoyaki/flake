{ pkgs, ... }:

{
  time.hardwareClockInLocalTime = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    loader.efi.canTouchEfiVariables = true;

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "boot.shell_on_fail"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=0"
      "udev.log_priority=0"
    ];

    plymouth.enable = true;
  };
}
