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
      filterAttrs (_: iCfg: iCfg.group == null) cfg.instances
    );

    users.users = mapAttrs' (
      iName: iCfg:
      nameValuePair "suwayomi-${iName}" {
        group = nullOr iCfg.group "suwayomi-${iName}";
        home = nullOr iCfg.settings.server.rootDir "/var/lib/suwayomi/${iName}";
        description = "Suwayomi Daemon user";
        isSystemUser = true;
      }
    ) (filterAttrs (_: iCfg: iCfg.user == null) cfg.instances);

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

        user = nullOr iCfg.user "suwayomi-${iName}";
        group = nullOr iCfg.group "suwayomi-${iName}";

        configFile = format.generate "server.conf" (
          filterAttrsRecursive (_: x: x != null) (
            recursiveUpdate iCfg.settings {
              server = {
                systemTrayEnabled = false;
                initialOpenInBrowserEnabled = false;
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

        environment.JAVA_TOOL_OPTIONS = "-Djava.io.tmpdir=${dataDir}/tmp -Dsuwayomi.tachidesk.config.server.rootDir=${dataDir}";

        script = ''
          ${getExe pkgs.envsubst} -i ${configFile} -o ${dataDir}/server.conf

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
