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
    mkOption
    nameValuePair
    types
    ;

  format = pkgs.formats.hocon { };

  version = "1.1.1";
  revision = 1535;

  jarFile = pkgs.fetchurl {
    url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${version}/Suwayomi-Server-v${version}-r${toString revision}.jar";
    hash = "sha256-mPzREuH89RGhZLK+5aIPuq1gmNGc9MGG0wh4ZV5dLTg=";
  };
in

{
  options.services.suwayomi = {
    enable = mkEnableOption "multiple suwayomi instances";

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
    networking.firewall.allowedTCPPorts = builtins.map (
      instance: cfg.instances.${instance}.settings.server.port
    ) (builtins.attrNames cfg.instances);

    users.groups = mapAttrs' (name: instCfg: nameValuePair "suwayomi-${name}" { }) cfg.instances;

    users.users = mapAttrs' (
      name: instCfg:
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
      name: instCfg:
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

          ${lib.getExe pkgs.jdk17_headless} \
            -Djava.io.tmpdir=${dataDir}/tmp \
            -jar ${jarFile}
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
