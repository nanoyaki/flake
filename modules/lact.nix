{ config, ... }:

{
  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.lact ];

    services.lact.settings = {
      version = 7;
      daemon = {
        log_level = "info";
        admin_group = "wheel";
        disable_clocks_cleanup = false;
      };

      apply_settings_timer = 5;
      gpus."1002:744C-1043:0506-0000:08:00.0" = {
        fan_control_enabled = true;
        fan_control_settings = {
          mode = "curve";
          static_speed = 0.5;
          temperature_key = "edge";
          interval_ms = 500;
          curve = {
            "55" = 0.3;
            "70" = 0.4;
            "80" = 0.55;
            "85" = 0.7;
            "90" = 1.0;
          };
          spindown_delay_ms = 5000;
          change_threshold = 2;
        };
        pmfw_options.zero_rpm = true;
        performance_level = "auto";
        voltage_offset = -72;
        max_memory_clock = 1250;
      };
      current_profile = null;
      auto_switch_profiles = false;
    };
  };

  modules.nixos.lact =
    { lib, pkgs, ... }:

    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        types
        mkIf
        ;

      cfg = config.services.lact;
      format = (pkgs.formats.yaml_1_1 { }) // {
        generate =
          name: value:
          pkgs.callPackage (
            {
              runCommand,
              remarshal,
              yq-go,
            }:
            runCommand name
              {
                nativeBuildInputs = [
                  remarshal
                  yq-go
                ];
                value = builtins.toJSON value;
                passAsFile = [ "value" ];
                preferLocalBuild = true;
              }
              ''
                remarshal --from json --to yaml-1.1 "$valuePath" raw.yaml
                yq -o=yaml '.gpus[].fan_control_settings.curve |= with_entries(.key |= tonumber)' raw.yaml > "$out"
              ''
          ) { };
      };

      configFile = format.generate "lact-config.yaml";
    in

    {
      disabledModules = [ "services/hardware/lact.nix" ];

      options.services.lact = {
        enable = mkEnableOption "lact" // {
          default = true;
        };

        package = mkPackageOption pkgs "lact" { };

        settings = mkOption {
          type = types.submodule {
            freeformType = format.type;
          };
        };
      };

      config = {
        environment.systemPackages = [ cfg.package ];
        systemd.packages = [ cfg.package ];

        environment.etc."lact/config.yaml" = mkIf (cfg.settings != { }) {
          source = configFile;
        };

        systemd.services.lactd = {
          description = "LACT GPU Control Daemon";
          wantedBy = [ "multi-user.target" ];

          # Restart when the config file changes.
          restartTriggers = mkIf (cfg.settings != { }) [ configFile ];
        };
      };
    };
}
