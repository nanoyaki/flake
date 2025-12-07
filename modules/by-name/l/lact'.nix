{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lact';
  configFormat = pkgs.formats.yaml { };
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
    enable = lib.mkEnableOption "lact";

    package = lib.mkPackageOption pkgs "lact" { };

    settings = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        freeformType = configFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    environment.etc."lact/config.yaml".source = configFile.outPath;

    systemd.services.lactd = {
      description = "LACT GPU Control Daemon";
      wantedBy = [ "multi-user.target" ];

      restartTriggers = lib.mkIf (cfg.settings != { }) [ configFile ];
    };
  };
}
