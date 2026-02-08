{
  flake.nixosModules.shirayuri-cooling =
    { config, ... }:

    {
      boot = {
        kernelParams = [ "acpi_enforce_resources=lax" ];
        kernelModules = [ "it87" ];
        extraModulePackages = [ config.boot.kernelPackages.it87 ];
        extraModprobeConfig = ''
          options it87 force_id=0x8628
        '';
      };

      programs.coolercontrol.enable = true;
    };
}
