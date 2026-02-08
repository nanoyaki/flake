{
  flake.nixosModules.lact =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        types
        mkIf
        ;

      cfg = config.services.lact';

      configFile = pkgs.callPackage (
        {
          runCommand,
          remarshal_0_17,
          yq-go,
        }:
        runCommand "lact-config.yaml"
          {
            nativeBuildInputs = [
              remarshal_0_17
              yq-go
            ];
            value = builtins.toJSON cfg.settings;
            passAsFile = [ "value" ];
            preferLocalBuild = true;
          }
          ''
            json2yaml "$valuePath" raw.yaml
            yq -o=yaml '.gpus[].fan_control_settings.curve |= with_entries(.key |= tonumber)' raw.yaml > "$out"
          ''
      ) { };
    in

    {
      meta.maintainers = [ lib.maintainers.nanoyaki ];

      options.services.lact' = {
        enable = mkEnableOption "lact";

        package = mkPackageOption pkgs "lact" { };

        settings = mkOption {
          default = { };
          type = types.submodule {
            freeformType = (pkgs.formats.yaml { }).type;
          };
        };
      };

      config = mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];
        systemd.packages = [ cfg.package ];

        environment.etc."lact/config.yaml".source = configFile.outPath;

        systemd.services.lactd = {
          description = "LACT GPU Control Daemon";
          wantedBy = [ "multi-user.target" ];

          restartTriggers = mkIf (cfg.settings != { }) [ configFile ];
        };
      };
    };
}
