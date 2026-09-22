# { config, ... }:
_:

{
  modules.nixos.setup =
    { lib, config, ... }:

    let
      inherit (lib)
        mkOption
        types
        mkEnableOption
        mapAttrsToList
        mkIf
        ;

      cfg = config.services.setup;
    in

    {
      options.services.setup = {
        enable = mkEnableOption "setup mode" // {
          default = true;
        };

        modules = mkOption {
          type = types.attrsOf types.str;
          default = { };
        };
      };

      config = mkIf cfg.enable {
        warnings = mapAttrsToList (service: cfg: "- ${service}: ${cfg}") (cfg.modules);
      };
    };

  modules.nixos.usbguard =
    {
      lib,
      options,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = lib.optionalAttrs (options ? services.setup) (
        mkIf (config.services.setup.enable or false) {
          services.setup.modules.usbguard = "this service is temporarily disabled. Make sure to run `usbguard generate-policy` for an initial device configuration.";
        }
      );
    };

  modules.nixos.sops =
    {
      lib,
      options,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = lib.optionalAttrs (options ? services.setup) (
        mkIf (config.services.setup.enable or false) {
          services.setup.modules.sops = "remember to configure a key file.";
        }
      );
    };

  modules.nixos.limine =
    {
      lib,
      pkgs,
      options,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = lib.optionalAttrs (options ? services.setup) (
        mkIf (config.services.setup.enable or false) {
          environment.systemPackages = [ pkgs.sbctl ];
          services.setup.modules.limine = "secure boot is not set up. Use `sbctl` to set it up.";
        }
      );
    };

  modules.nixos.hardware =
    {
      lib,
      pkgs,
      options,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = lib.optionalAttrs (options ? services.setup) (
        mkIf (config.services.setup.enable or false) {
          environment.systemPackages = [ pkgs.nixos-facter ];
          services.setup.modules.hardware = "hardware configuration is not set up. Use `nixos-facter` to generate one.";
        }
      );
    };
}
