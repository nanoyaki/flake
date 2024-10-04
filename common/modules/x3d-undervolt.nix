{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    ;

  cfg = config.services.x3d-undervolt;
in
{
  options.services.x3d-undervolt = {
    enable = mkEnableOption "Ryzen 7 5800X3D undervolting";

    cores = mkOption {
      type = types.int;
      default = 0;
      example = 8;
      description = ''
        The amount of cores to apply the undervolt to.
      '';
    };

    milivolts = mkOption {
      type = types.int;
      default = 8;
      example = 30;
      description = ''
        The milivoltage to reduce on the cores.
      '';
    };
  };

  config = mkIf cfg.enable {
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.cpu.amd.ryzen-smu.enable = true;

    systemd.services.x3d-undervolt = {
      enable = true;
      description = "Undervolt for the Ryzen 7 5800X3D";

      wantedBy = [ "multi-user.target" ];

      script = ''
        ${
          lib.getExe (pkgs.callPackage ../pkgs/x3d-undervolt/package.nix { })
        } -c ${toString cfg.cores} -o -${toString cfg.milivolts}
      '';

      serviceConfig = {
        User = "root";
        Group = "wheel";
      };
    };
  };
}
