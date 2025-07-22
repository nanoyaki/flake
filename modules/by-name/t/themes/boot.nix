{
  lib,
  lib',
  config,
  ...
}:

{
  options.config'.theming.plymouth.enable = lib'.options.mkFalseOption;

  config = lib.mkIf config.config'.theming.plymouth.enable {
    boot = {
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
  };
}
