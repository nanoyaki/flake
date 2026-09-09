{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.rustic ];
  };

  modules.nixos.rustic =
    {
      config,
      lib,
      pkgs,
      utils,
      ...
    }:

    let
      inherit (utils.systemdUtils.unitOptions) unitOption;

      inherit (lib)
        getExe
        mkDefault
        mkIf
        mkOption
        mkPackageOption
        mapAttrs'
        mapAttrsToList
        nameValuePair
        optionalAttrs
        escapeShellArg
        types
        ;

      cfg = config.services.rustic;
      format = pkgs.formats.toml { };

      mkProfileConfig =
        name: backup:
        (removeAttrs backup [
          "package"
          "paths"
          "exclude"
          "command"
          "timerConfig"
          "repositoryPath"
          "snapshot"
        ])
        // {
          global = {
            check-index = true;
          }
          // (backup.global or { });

          repository = {
            repository = backup.repositoryPath;
            no-cache = mkDefault true;
          }
          // (backup.repository or { });

          backup = {
            snapshots = [
              (
                (optionalAttrs (backup.command != "") {
                  inherit name;
                  sources = [ "-" ];
                  stdin-command = backup.command;
                  as-path = name;
                })
                // (optionalAttrs (backup.paths != [ ]) {
                  sources = backup.paths;
                  globs = map (path: "!${path}") backup.exclude;
                })
                // (backup.snapshot or { })
              )
            ];
          }
          // (backup.backup or { });

          forget = {
            keep-within-daily = "7 days";
            keep-weekly = 4;
            keep-monthly = 3;
            keep-yearly = 1;
          }
          // (backup.forget or { });
        };

      configDirOf =
        name: backup:

        pkgs.linkFarm "rustic-${name}-config" [
          {
            name = "rustic-${name}.toml";
            path = format.generate "rustic-${name}.toml" (mkProfileConfig name backup);
          }
        ];

      mkBackupService =
        name: backup:

        let
          profileName = "rustic-${name}";
          configDir = configDirOf name backup;
          rustic = getExe backup.package;
          repo = escapeShellArg backup.repositoryPath;
        in

        nameValuePair profileName {
          description = "Rustic backup ${name}";

          preStart = ''
            if [[ ! -d "${repo}" ]]; then
              ${rustic} init -P ${profileName} --log-level debug
            fi
          '';

          script = ''
            ${rustic} backup -P ${profileName} --log-level debug
            ${rustic} forget -P ${profileName} --log-level debug
          '';

          serviceConfig = {
            Type = "oneshot";
            WorkingDirectory = configDir;
            StateDirectory = "rustic";

            # Hardening
            CapabilityBoundingSet = [ "" ];
            DeviceAllow = [ "" ];
            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            PrivateUsers = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            ReadWritePaths = [ backup.repositoryPath ];
            RestrictAddressFamilies = [ "AF_UNIX" ];
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallFilter = [ "@system-service" ];
            UMask = "0077";
          };
        };

      mkBackupTimer =
        name: backup:

        nameValuePair "rustic-${name}" {
          inherit (backup) timerConfig;
          wantedBy = [ "timers.target" ];
        };

      mkWrapper =
        name: backup:

        let
          wrapperName = "rustic-${name}";
          configDir = configDirOf name backup;
        in

        pkgs.symlinkJoin {
          pname = wrapperName;
          inherit (backup.package) version;
          paths = [ backup.package ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            makeWrapper $out/bin/rustic $out/bin/${wrapperName} \
              --add-flags '-P' \
              --add-flags ${escapeShellArg wrapperName} \
              --chdir ${escapeShellArg configDir}
          '';
          meta = {
            mainProgram = wrapperName;
            inherit (backup.package.meta) platforms;
          };
        };
    in
    {
      options.services.rustic.backups = mkOption {
        type = types.attrsOf (
          types.submodule (
            { name, ... }:

            {
              freeformType = format.type;

              options = {
                package = mkPackageOption pkgs "rustic" { };

                repositoryPath = mkOption {
                  type = types.path;
                  default = "/var/backup/rustic/${name}";
                  defaultText = lib.literalExpression "/var/backup/rustic/\${name}";
                  description = ''
                    Path to the rustic repository. The directory is initialised
                    automatically on first run if it doesn't exist.
                  '';
                };

                paths = mkOption {
                  type = types.listOf types.path;
                  default = [ ];
                  description = ''
                    Paths to back up. Mutually exclusive with
                    {option}`services.rustic.backups.<name>.command`.
                  '';
                };

                exclude = mkOption {
                  type = types.listOf (types.strMatching ''^[^\!].+'');
                  default = [ ];
                  description = ''
                    Glob patterns to exclude from the backup. An bang in front
                    is added automatically.
                  '';
                };

                command = mkOption {
                  type = types.str;
                  default = "";
                  description = ''
                    Command whose stdout is captured as the backup.
                    Mutually exclusive with {option}`services.rustic.backups.<name>.paths`.
                  '';
                };

                timerConfig = mkOption {
                  type = types.attrsOf unitOption;
                  default = {
                    OnCalendar = "daily";
                    Persistent = true;
                    RandomizedDelaySec = "30min";
                  };
                  defaultText = lib.literalExpression ''
                    {
                      OnCalendar = "daily";
                      Persistent = true;
                      RandomizedDelaySec = "30min";
                    }
                  '';
                  description = ''
                    Configuration for the systemd timer.
                    See {manpage}`systemd.timer(5)` for the available options.
                  '';
                };
              };
            }
          )
        );
        default = { };
        description = ''
          Rustic backup definitions, indexed by name. Each entry generates
          a `rustic-<name>` systemd service and timer, plus a `rustic-<name>`
          wrapper script in {option}`environment.systemPackages` for manual
          invocations.
        '';
      };

      config = mkIf (cfg.backups != { }) {
        assertions = [
          {
            assertion = lib.all (
              backup:
              (backup.paths != [ ] && backup.command == "") || (backup.paths == [ ] && backup.command != "")
            ) (builtins.attrValues cfg.backups);
            message = ''
              Exactly one of `paths` or `command` must be set for each {option}`services.rustic.backups.<name>`.
            '';
          }
        ];

        environment.systemPackages = mapAttrsToList mkWrapper cfg.backups;

        systemd.services = mapAttrs' mkBackupService cfg.backups;
        systemd.timers = mapAttrs' mkBackupTimer cfg.backups;
      };
    };
}
