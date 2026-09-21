# { config, ... }:
_:

{
  modules.nixos.setup =
    { lib, config, ... }:

    let
      inherit (lib)
        mkOption
        types
        attrValues
        mkEnableOption
        concatMapStringsSep
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
        warnings = concatMapStringsSep "\n" (service: "- ${service}: ${cfg.modules.${service}}") (
          attrValues cfg.modules
        );
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
      inherit (lib) optionalAttrs;
    in

    {
      config = optionalAttrs ((options.services ? setup) && config.services.setup.enable) {
        services.setup.modules.usbguard = "this service is temporarily disabled. Make sure to run `usbguard generate-policy` for an initial device configuration.";
      };
    };

  modules.nixos.sops =
    {
      lib,
      options,
      config,
      ...
    }:

    let
      inherit (lib) optionalAttrs;
    in

    {
      config = optionalAttrs ((options.services ? setup) && config.services.setup.enable) {
        services.setup.modules.sops = "remember to configure a key file.";
      };
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
      inherit (lib) optionalAttrs;
    in

    {
      config = optionalAttrs ((options.services ? setup) && config.services.setup.enable) {
        environment.systemPackages = [ pkgs.sbctl ];
        services.setup.modules.limine = "secure boot is not set up. Use `sbctl` to set it up.";
      };
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
      inherit (lib) optionalAttrs;
    in

    {
      config = optionalAttrs ((options.services ? setup) && config.services.setup.enable) {
        environment.systemPackages = [ pkgs.nixos-facter ];
        services.setup.modules.hardware = "hardware configuration is not set up. Use `nixos-facter` to generate one.";
      };
    };
}
