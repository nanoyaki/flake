{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;

  cfg = config.programs.wakatime;
  format = pkgs.formats.ini { };

  wrapEnvVars =
    pkg: variables:
    pkgs.writeShellScriptBin (pkg.pname or pkg.name) (
      let
        parsedEnvVars = builtins.concatStringsSep " " (
          lib.mapAttrsToList (name: value: "${name}=${value}") variables
        );
      in
      ''${parsedEnvVars} ${lib.getExe pkg}''
    );
in

{
  options.programs.wakatime = {
    enable = mkEnableOption "wakatime";

    package = mkPackageOption pkgs "wakatime-cli" { };

    configHome = mkOption {
      type = types.str;
      default =
        if (config.xdg.configHome != null) then
          "${config.xdg.configHome}/wakatime"
        else
          "${config.home.homeDirectory}/.config/wakatime";
      example = lib.literalExpression "$HOME";
      description = ''
        The directory that should contain the {file}`.wakatime.cfg` file.
      '';
    };

    settings = mkOption {
      type = types.submodule { freeformType = format.type; };
      default = { };
      description = ''
        Configuration to write to {file}`.wakatime.cfg`.
        See <https://github.com/wakatime/wakatime-cli/blob/v1.107.0/USAGE.md#ini-config-file> for the full documentation.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      (wrapEnvVars cfg.package {
        WAKATIME_HOME = cfg.configHome;
      })
    ];

    xdg.configFile = mkIf (cfg.settings != { }) {
      "${cfg.configHome}/.wakatime.cfg".source = format.generate ".wakatime.cfg" cfg.settings;
    };
  };
}
