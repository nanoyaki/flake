{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.hardware ];
  };

  modules.nixos.hardware =
    { lib, config, ... }:

    let
      inherit (lib) mkDefault;

      cfg = config.hardware.facter.report;
      cpu = builtins.elemAt cfg.hardware.cpu 0;
    in

    {
      assertions = [
        {
          assertion = config.hardware.facter.reportPath != null;
          message = ''
            The `hardware` module requires {option}`hardware.facter.reportPath` to be set.
          '';
        }
      ];

      nixpkgs.hostPlatform = { inherit (cfg) system; };

      hardware.cpu.amd.updateMicrocode = mkDefault (cpu.vendor_name == "GenuineAMD");
      hardware.cpu.intel.updateMicrocode = mkDefault (cpu.vendor_name == "GenuineIntel");

      hardware.bluetooth.enable = mkDefault (cfg.hardware ? bluetooth);

      hardware.enableRedistributableFirmware = true;
    };
}
