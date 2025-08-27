{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib'.options)
    mkFalseOption
    mkTrueOption
    mkStrOption
    mkAttrsOf
    mkOneOf
    mkPathOption
    mkNullOr
    mkListOf
    mkDefault
    ;
  inherit (lib)
    mkIf
    mkPackageOption
    concatMapStringsSep
    attrNames
    mkForce
    mkMerge
    ;

  cfg = config.config'.fireshare;
  finalEnv = {
    FLASK_APP = "${cfg.package}/share/fireshare/server/fireshare:create_app()";
    DATA_DIRECTORY = "${cfg.dataDir}/data";
    VIDEO_DIRECTORY = "${cfg.dataDir}/videos";
    PROCESSED_DIRECTORY = "${cfg.dataDir}/processed";
    TEMPLATE_PATH = "${cfg.package}/share/fireshare/server/fireshare/templates";
    ENVIRONMENT = "production";
    FLASK_ENV = "production";
  }
  // cfg.environment;
in

{
  options.config'.fireshare = {
    enable = mkFalseOption;

    package = mkPackageOption pkgs "fireshare" { };

    backendListenAddress = mkDefault "127.0.0.1:5000" mkStrOption;

    user = mkDefault "fireshare" mkStrOption;
    group = mkDefault "fireshare" mkStrOption;

    dataDir = mkDefault "/var/lib/fireshare" mkStrOption;

    enableWrappedCli = mkTrueOption;

    environment = mkAttrsOf (
      mkNullOr (mkOneOf [
        mkStrOption
        mkPathOption
      ])
    );

    environmentFile = mkDefault null (mkNullOr mkPathOption);

    extraArgs = mkDefault [
      "--workers"
      "3"
      "--threads"
      "3"
      "--preload"
    ] (mkListOf mkStrOption);
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.enableWrappedCli [
      (pkgs.symlinkJoin {
        name = "fireshare";
        paths = [ pkgs.fireshare ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/fireshare" \
            ${concatMapStringsSep " \\\n" (var: ''--set ${var} "${finalEnv.${var}}"'') (attrNames finalEnv)}
        '';
        postFixup = ''
          rm $out/bin/fireshare-server
        '';
      })
    ];

    users.users = mkMerge [
      { ${config.services.caddy.user}.extraGroups = [ cfg.group ]; }
      (mkIf (cfg.user == "fireshare") {
        fireshare = {
          isSystemUser = true;
          home = cfg.dataDir;
          homeMode = "770";
          inherit (cfg) group;
        };
      })
    ];

    users.groups = mkIf (cfg.group == "fireshare") {
      fireshare = { };
    };

    services.caddy = {
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddyserver/cache-handler@v0.16.0" ];
        hash = "sha256-yWHaTI5jto7x27NzBMtnM47Y0wZ9zt1M0IHSeNOOUvM=";
      };

      globalConfig = mkForce ''
        ${lib.optionalString (!config.config'.caddy.useHttps) "auto_https disable_redirects"}
        cache
      '';

      virtualHosts.${finalEnv.DOMAIN}.extraConfig = ''
        header -Server
        root * ${cfg.package}/share/fireshare/client
        file_server

        encode {
          minimum_length 256
          gzip 6
        }

        handle_path /_content/* {
          root * ${cfg.dataDir}/processed

          cache {
            ttl 10m
            stale 1h
          }
        }

        handle_path /_content/video/* {
          header {
            Accept-Ranges bytes
            Cache-Control "public, max-age=3600"
          }

          root * ${cfg.dataDir}/processed/video_links
        }

        handle /api/* {
          reverse_proxy ${cfg.backendListenAddress} {
            transport http {
              versions 1.1
              dial_timeout 60s
            }
          }

          request_body {
            max_size 0
          }
        }

        handle /w/* {
          reverse_proxy ${cfg.backendListenAddress} {
            transport http {
              versions 1.1
              dial_timeout 60s
              read_timeout 60s
            }
          }
        }
      '';
    };

    systemd.tmpfiles.settings."10-fireshare" =
      let
        dirCfg = {
          inherit (cfg) user group;
          mode = "0770";
        };
      in
      {
        ${cfg.dataDir}.d = dirCfg;
        "${cfg.dataDir}/data".d = dirCfg;
        "${cfg.dataDir}/videos".d = dirCfg;
        "${cfg.dataDir}/processed".d = dirCfg;
        "${config.users.users.${cfg.user}.home}/.local/state".d = dirCfg;
      };

    systemd.services.fireshare-init-db = {
      wantedBy = [ "multi-user.target" ];
      before = [ "fireshare.service" ];

      environment = finalEnv;

      unitConfig.ConditionFileNotEmpty = "!${finalEnv.DATA_DIRECTORY}/db.sqlite";

      serviceConfig = {
        ExecStart = "${lib.getExe' cfg.package "fireshare"} init-db";
        StateDirectory = ".local/state";
        WorkingDirectory = cfg.dataDir;

        User = cfg.user;
        Group = cfg.group;

        Type = "oneshot";
        Restart = "no";
      };
    };

    systemd.services.fireshare = {
      wantedBy = [ "network-online.target" ];

      environment = finalEnv;

      path = [ cfg.package ];

      script = ''
        jobsDb="${finalEnv.DATA_DIRECTORY}/jobs.sqlite"
        [[ -f "$jobsDb" ]] && rm "$jobsDb"

        fireshare-server \
          --bind="${cfg.backendListenAddress}" \
          --user "${cfg.user}" --group "${cfg.group}" \
          ${lib.escapeShellArgs cfg.extraArgs}
      '';

      unitConfig.ConditionFileNotEmpty = "${finalEnv.DATA_DIRECTORY}/db.sqlite";
      serviceConfig = {
        StateDirectory = ".local/state";
        WorkingDirectory = cfg.dataDir;

        User = cfg.user;
        Group = cfg.group;

        Type = "simple";
        Restart = "on-failure";
      }
      // lib.optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };
  };
}
