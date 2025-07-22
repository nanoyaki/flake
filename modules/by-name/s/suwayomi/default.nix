{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    types
    mkIf
    getExe
    ;

  inherit (lib.attrsets)
    filterAttrs
    nameValuePair
    mapAttrs'
    recursiveUpdate
    filterAttrsRecursive
    ;

  inherit (lib.lists) map;
  inherit (builtins) attrNames;

  cfg = config.services.suwayomi;
  nullOr = value: alternative: if value != null then value else alternative;

  format = pkgs.formats.hocon { };

  dirCfg.d = {
    user = "suwayomi";
    group = "suwayomi";
    mode = "770";
  };
in

{
  options.services.suwayomi = {
    enable = mkEnableOption "multiple suwayomi instances";

    package = mkPackageOption pkgs "suwayomi-server" { };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/suwayomi";
      example = "/srv/suwayomi";
    };

    instances = mkOption {
      type = types.attrsOf (types.submodule (import ./instance.nix { inherit lib format; }));
      default = { };
    };
  };

  config = mkIf (cfg.enable && cfg.instances != { }) {
    networking.firewall.allowedTCPPorts = map (iName: cfg.instances.${iName}.settings.server.port) (
      attrNames (filterAttrs (_: iCfg: iCfg.openFirewall) cfg.instances)
    );

    users.groups.suwayomi = { };

    users.users.suwayomi = {
      group = "suwayomi";
      home = cfg.dataDir;
      description = "Suwayomi Daemon user";
      isSystemUser = true;
    };

    systemd.tmpfiles.settings = {
      "10-suwayomi" = {
        "${cfg.dataDir}/.downloads" = { inherit (dirCfg) d; };
        "${cfg.dataDir}/.localSources" = { inherit (dirCfg) d; };
        "${cfg.dataDir}/.cache/suwayomi" = { inherit (dirCfg) d; };
      };
    }
    // (mapAttrs' (
      iName: iCfg:
      nameValuePair "10-suwayomi-${iName}" {
        ${nullOr iCfg.settings.server.rootDir "${cfg.dataDir}/${iName}"} = { inherit (dirCfg) d; };
      }
    ) cfg.instances);

    systemd.services = mapAttrs' (
      iName: iCfg:
      let
        dataDir = nullOr iCfg.settings.server.rootDir "${cfg.dataDir}/${iName}";

        configFile = format.generate "server.conf" (
          filterAttrsRecursive (_: x: x != null) (
            recursiveUpdate iCfg.settings {
              server = {
                systemTrayEnabled = false;
                initialOpenInBrowserEnabled = false;
                localSourcePath = "${cfg.dataDir}/.localSources";
                downloadsPath = "${cfg.dataDir}/.downloads";
              };
            }
          )
        );
      in
      nameValuePair "suwayomi-${iName}" {
        description = "Suwayomi Server instance ${iName}";

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        environment.JAVA_TOOL_OPTIONS = "-Djava.io.tmpdir=${cfg.dataDir}/.cache/suwayomi -Dsuwayomi.tachidesk.config.server.rootDir=${dataDir}";

        script = ''
          ${getExe pkgs.envsubst} -i ${configFile} -o ${dataDir}/server.conf

          ${getExe cfg.package}
        '';

        serviceConfig = {
          User = "suwayomi";
          Group = "suwayomi";

          Type = "simple";
          Restart = "on-failure";
        };
      }
    ) cfg.instances;
  };
}
