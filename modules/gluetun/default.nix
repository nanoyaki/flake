{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkIf
    mkOption
    types
    mkEnableOption
    mkPackageOption
    ;

  cfg = config.services.gluetun;

  dataDirEnv = {
    GLUETUN_HOME = cfg.dataDir;
    STORAGE_FILEPATH = "${cfg.dataDir}/servers.json";
    HTTP_CONTROL_SERVER_AUTH_CONFIG_FILEPATH = "${cfg.dataDir}/auth/config.toml";
  };

  gluetunExe = lib.getExe cfg.package;
in

{
  options.services.gluetun = {
    enable = mkEnableOption "gluetun";

    package = mkPackageOption pkgs "gluetun" { };

    createWrapper = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Whether to create a wrapper script containing the variables defined in
        the {option}`services.gluetun.dataDir` option to add to the system
        environment.

        This is recommended as else gluetun will generate directories in root.
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/gluetun";
      example = "/srv/gluetun";
      description = ''
        Sets the {env}`STORAGE_FILEPATH` and
        {env}`HTTP_CONTROL_SERVER_AUTH_CONFIG_FILEPATH` environment variables.

        See <https://github.com/qdm12/gluetun-wiki/blob/main/setup/options/storage.md>
        for further documentation.
      '';
    };

    environment = mkOption {
      type =
        with types;
        attrsOf (
          nullOr (oneOf [
            str
            path
            package
          ])
        );
      default = { };
      example = lib.literalExpression ''
        {
          VPN_SERVICE_PROVIDER = "mullvad";
          VPN_TYPE = "wireguard";
        }
      '';
      description = ''
        Environment variables to add to the service environment.

        See <https://github.com/qdm12/gluetun-wiki/tree/main/setup/options> for
        available environment variables.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/run/secrets/gluetun";
      description = ''
        A file containing secret environment variables like {env}`WIREGUARD_PRIVATE_KEY`
        to add to the service environment.

        See <https://github.com/qdm12/gluetun-wiki/blob/main/setup/options/openvpn.md> and
        <https://github.com/qdm12/gluetun-wiki/blob/main/setup/options/wireguard.md> for
        available environment variables.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "wireguard" ];

    systemd.services.gluetun = {
      description = "Gluetun";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ iptables ];

      environment = dataDirEnv // cfg.environment;

      serviceConfig = {
        Type = "simple";
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = gluetunExe;
        Restart = "on-failure";
      };

      enableStrictShellChecks = true;
    };

    environment.systemPackages = mkIf cfg.createWrapper [
      (pkgs.writeShellScriptBin "gluetun" ''
        set -a
        # set data dir env vars
        ${lib.pipe dataDirEnv [
          (lib.mapAttrs (_: value: "${value}"))
          lib.toShellVars
        ]}

        exec ${gluetunExe} "$@"
      '')
    ];
  };
}
