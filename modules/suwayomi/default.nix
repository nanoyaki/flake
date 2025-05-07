{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.suwayomi;
  inherit (lib)
    recursiveUpdate
    filterAttrsRecursive
    mapAttrs'
    mkEnableOption
    mkPackageOption
    mkOption
    nameValuePair
    types
    ;

  format = pkgs.formats.hocon { };
in

{
  options.services.suwayomi = {
    enable = mkEnableOption "multiple suwayomi instances";

    package = mkPackageOption pkgs "suwayomi-server" { };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/suwayomi";
      example = "/var/data/mangas";
      description = ''
        The path to the data directory in which Suwayomi-Server will download scans.
      '';
    };

    instances = mkOption {
      type = types.attrsOf (types.submodule (import ./instance.nix { inherit lib format; }));
      default = { };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.instances != { }) {
    # networking.firewall.allowedTCPPorts = builtins.map (
    #   instance: cfg.instances.${instance}.settings.server.port
    # ) (builtins.attrNames cfg.instances);

    users.groups = mapAttrs' (name: _: nameValuePair "suwayomi-${name}" { }) cfg.instances;

    users.users = mapAttrs' (
      name: _:
      let
        dataDir = "${cfg.dataDir}/${name}";
        user = "suwayomi-${name}";
      in
      nameValuePair user {
        group = user;
        home = dataDir;
        description = "Suwayomi Daemon user";
        isSystemUser = true;
      }
    ) cfg.instances;

    systemd.tmpfiles.settings = mapAttrs' (
      name: _:
      let
        dataDir = "${cfg.dataDir}/${name}";
        user = "suwayomi-${name}";

        dirConf = {
          mode = "0700";
          inherit user;
          group = user;
        };
      in
      nameValuePair "10-${user}" {
        "${dataDir}/.local/share/Tachidesk".d = dirConf;
        "${dataDir}/tmp".d = dirConf;
      }
    ) cfg.instances;

    systemd.services = mapAttrs' (
      name: instCfg:
      let
        dataDir = "${cfg.dataDir}/${name}";
        localsDir = "${dataDir}/locals";
        downloadsDir = "${dataDir}/downloads";

        serverName = "suwayomi-${name}";

        instanceSettings = recursiveUpdate instCfg.settings {
          server = {
            rootDir = dataDir;
            localSourcePath = localsDir;
            downloadsPath = downloadsDir;

            systemTrayEnabled = false;
            initialOpenInBrowserEnabled = false;
          };
        };

        filteredSettings = filterAttrsRecursive (_: x: x != null) instanceSettings;

        configFile = format.generate "server.conf" filteredSettings;
      in
      nameValuePair serverName {
        inherit (instCfg) enable;

        description = ''Instance "${name}" of Suwayomi Server.'';

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        script = ''
          ${lib.getExe pkgs.envsubst} -i ${configFile} -o ${dataDir}/.local/share/Tachidesk/server.conf

          JAVA_OPTS="${dataDir}/tmp"
          ${lib.getExe cfg.package}
        '';

        serviceConfig = {
          User = serverName;
          Group = serverName;

          Type = "simple";
          Restart = "on-failure";

          StateDirectory = serverName;
        };
      }
    ) cfg.instances;
  };
}
