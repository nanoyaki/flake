{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.multi-suwayomi-server;
  inherit (lib) mapAttrs mkOption mkIf types;

  format = pkgs.formats.hocon {};
in {
  options = {
    services.multi-suwayomi-server = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          # Basepath /var/lib/<instanceName>-suwayomi-server
          settings = mkOption {
            type = types.submodule {
              freeformType = format.type;
              options = {
                server = {
                  ip = mkOption {
                    type = types.str;
                    default = "0.0.0.0";
                    example = "127.0.0.1";
                    description = ''
                      The IP address that Suwayomi will bind to.
                    '';
                  };

                  port = mkOption {
                    type = types.port;
                    default = 8080;
                    example = 4567;
                    description = ''
                      The port that Suwayomi will listen to.
                    '';
                  };

                  downloadAsCbz = mkOption {
                    type = types.bool;
                    default = false;
                    description = ''
                      Download chapters as `.cbz` files.
                    '';
                  };

                  extensionRepos = mkOption {
                    type = types.listOf types.str;
                    default = [];
                    example = [
                      "https://raw.githubusercontent.com/MY_ACCOUNT/MY_REPO/repo/index.min.json"
                    ];
                    description = ''
                      URL of repositories from which the extensions can be installed.
                    '';
                  };
                };
              };
            };
            description = ''
              Configuration to write to {file}`server.conf`.
              See <https://github.com/Suwayomi/Suwayomi-Server/wiki/Configuring-Suwayomi-Server> for more information.
            '';
            default = {};
            example = {
              server.socksProxyEnabled = true;
              server.socksProxyHost = "yourproxyhost.com";
              server.socksProxyPort = 8080;
            };
          };
        };
      });
      description = "The instance configuration for Suwayomi Server.";
    };
  };

  config = mkIf (cfg != {}) {
    networking.firewall.allowedTCPPorts = lib.attrValues (
      mapAttrs (serverName: serverConfig: serverConfig.settings.server.port) cfg
    );

    users.groups =
      lib.concatMapAttrs (serverName: serverConfig: {
        "${serverName}-suwayomi" = {};
      })
      cfg;

    users.users =
      lib.concatMapAttrs (serverName: serverConfig: {
        "${serverName}-suwayomi" = {
          group = "${serverName}-suwayomi";
          # Need to set the user home because the package writes to ~/.local/Tachidesk
          home = "/var/lib/${serverName}-suwayomi-server";
          description = "Suwayomi Daemon user for instance ${serverName}";
          isSystemUser = true;
        };
      })
      cfg;

    systemd.tmpfiles.settings =
      lib.concatMapAttrs (serverName: serverConfig: let
        user = "${serverName}-suwayomi";
        group = user;
      in {
        "10-suwayomi-server-${serverName}" = {
          "/var/lib/${serverName}-suwayomi-server/.local/share/Tachidesk".d = {
            mode = "0700";
            inherit user group;
          };
        };
      })
      cfg;

    systemd.services =
      lib.concatMapAttrs (serverName: serverConfig: {
        "suwayomi-server-${serverName}" = let
          dataDir = "/var/lib/${serverName}-suwayomi-server";
          user = "${serverName}-suwayomi";
          group = user;
          configFile = format.generate "server.conf" (lib.pipe (lib.mkMerge [
              {
                localSourcePath = dataDir;
              }
              serverConfig.settings
            ]) [
              (lib.filterAttrsRecursive (_: x: x != null))
            ]);
        in {
          description = "Instance \"${serverName}\" of Suwayomi Server.";

          wantedBy = ["multi-user.target"];
          wants = ["network-online.target"];
          after = ["network-online.target"];

          script = ''
            ${lib.getExe pkgs.envsubst} -i ${configFile} -o ${dataDir}/.local/share/Tachidesk/server.conf
            ${lib.getExe pkgs.suwayomi-server} -Dsuwayomi.tachidesk.config.server.rootDir=${dataDir}
          '';

          serviceConfig = {
            User = user;
            Group = group;

            Type = "simple";
            Restart = "on-failure";

            StateDirectory = "${serverName}-suwayomi-server";
          };
        };
      })
      cfg;
  };
}
