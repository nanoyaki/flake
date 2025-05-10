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
in

{
  options.services.suwayomi = {
    enable = mkEnableOption "multiple suwayomi instances";

    package = mkPackageOption pkgs "suwayomi-server" { };

    instances = mkOption {
      type = types.attrsOf (types.submodule (import ./instance.nix { inherit lib format; }));
      default = { };
    };
  };

  config = mkIf (cfg.enable && cfg.instances != { }) {
    networking.firewall.allowedTCPPorts = map (iName: cfg.instances.${iName}.settings.server.port) (
      attrNames (filterAttrs (_: iCfg: iCfg.openFirewall) cfg.instances)
    );

    users.groups = mapAttrs' (iName: _: nameValuePair "suwayomi-${iName}" { }) (
      filterAttrs (iName: iCfg: iCfg.group == "suwayomi-${iName}") cfg.instances
    );

    users.users = mapAttrs' (
      iName: iCfg:
      nameValuePair "suwayomi-${iName}" {
        group = nullOr iCfg.group "suwayomi-${iName}";
        home = nullOr iCfg.settings.server.rootDir "/var/lib/suwayomi/${iName}";
        description = "Suwayomi Daemon user";
        isSystemUser = true;
      }
    ) (filterAttrs (iName: iCfg: iCfg.user == "suwayomi-${iName}") cfg.instances);

    systemd.tmpfiles.settings = mapAttrs' (
      iName: iCfg:
      let
        dataDir = nullOr iCfg.settings.server.rootDir "/var/lib/suwayomi/${iName}";
        downloadsDir = nullOr iCfg.settings.server.downloadsPath "${dataDir}/downloads";
        localDir = nullOr iCfg.settings.server.localSourcePath "${dataDir}/local";

        dirCfg = {
          user = "suwayomi-${iName}";
          group = "suwayomi-${iName}";
          mode = "750";
        };
      in
      nameValuePair "10-suwayomi-${iName}" {
        "${dataDir}/.local/share/Tachidesk".d = dirCfg;
        "${dataDir}/tmp".d = dirCfg;
        ${downloadsDir}.d = dirCfg;
        ${localDir}.d = dirCfg;
      }
    ) cfg.instances;

    systemd.services = mapAttrs' (
      iName: iCfg:
      let
        dataDir = nullOr iCfg.settings.server.rootDir "/var/lib/suwayomi/${iName}";

        user = "suwayomi-${iName}";
        group = "suwayomi-${iName}";

        configFile =
          lib.pipe
            {
              server = {
                systemTrayEnabled = false;
                initialOpenInBrowserEnabled = false;
              };
            }
            [
              (recursiveUpdate iCfg.settings)
              (filterAttrsRecursive (_: x: x != null))
              (format.generate "server.conf")
            ];
      in
      nameValuePair "suwayomi-${iName}" {
        description = "Suwayomi Server instance ${iName}";

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        script = ''
          ${getExe pkgs.envsubst} -i ${configFile} -o ${dataDir}/.local/share/Tachidesk/server.conf

          export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=${dataDir}/tmp -Dsuwayomi.tachidesk.config.server.rootDir=${dataDir}"
          ${getExe cfg.package}
        '';

        serviceConfig = {
          User = user;
          Group = group;

          Type = "simple";
          Restart = "on-failure";
        };
      }
    ) cfg.instances;
  };
}
