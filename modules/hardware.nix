{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.hardware ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.hardware ];
  };

  modules.nixos.hardware =
    { lib, config, ... }:

    let
      inherit (lib)
        mkOverride
        mkIf
        any
        ;

      /*
        Override the nixpkgs nixos module but let the user
        defaults easily override it themselves.
      */
      mkHardwareDefault = mkOverride 900;

      cfg = config.hardware.facter.report;
      cpu = builtins.head cfg.hardware.cpu;
      hasTouchpad = any (device: device.base_class.name == "touchpad") cfg.hardware.mouse;
    in

    {
      config = mkIf config.hardware.facter.enable {
        nixpkgs.hostPlatform = { inherit (cfg) system; };

        hardware.graphics.enable = mkHardwareDefault (cfg.hardware ? graphics_card);
        hardware.graphics.enable32Bit = mkHardwareDefault (cfg.hardware ? graphics_card);

        boot.loader.efi.canTouchEfiVariables = mkHardwareDefault cfg.uefi.supported;

        hardware.cpu.amd.updateMicrocode = mkHardwareDefault (cpu.vendor_name == "GenuineAMD");
        hardware.cpu.intel.updateMicrocode = mkHardwareDefault (cpu.vendor_name == "GenuineIntel");

        hardware.bluetooth.enable = mkHardwareDefault (cfg.hardware ? bluetooth);

        hardware.enableRedistributableFirmware = true;

        services.libinput.enable = mkHardwareDefault true;
        services.libinput.touchpad.naturalScrolling = mkHardwareDefault hasTouchpad;
      };
    };
}
