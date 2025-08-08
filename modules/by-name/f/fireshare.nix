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
    getExe'
    concatMapStringsSep
    attrNames
    ;

  cfg = config.config'.fireshare;
  finalEnv = {
    FLASK_APP = "${cfg.package}/share/fireshare/server/fireshare:create_app()";
    DATA_DIRECTORY = "${cfg.dataDir}/data";
    VIDEO_DIRECTORY = "${cfg.dataDir}/videos";
    PROCESSED_DIRECTORY = "${cfg.dataDir}/processed";
    TEMPLATE_PATH = "${cfg.package}/share/fireshare/server/fireshare/templates";
    ENVIRONMENT = "production";
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
      "--workers 3"
      "--threads 3"
      "--preload"
    ] (mkListOf mkStrOption);
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.enableWrappedCli [
      (pkgs.symlinkJoin {
        name = "fireshare-cli";
        paths = [ pkgs.fireshare ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/fireshare-cli" \
            ${concatMapStringsSep " \\\n" (var: ''--prefix ${var} : "${finalEnv.${var}}"'') (
              attrNames finalEnv
            )}
        '';
        postFixup = ''
          rm $out/bin/fireshare-server
        '';
      })
    ];

    users.users = mkIf (cfg.user == "fireshare") {
      fireshare = {
        isSystemUser = true;
        home = cfg.dataDir;
        inherit (cfg) group;
      };
    };

    users.groups = mkIf (cfg.group == "fireshare") {
      fireshare = { };
    };

    services.caddy.virtualHosts.${finalEnv.DOMAIN}.extraConfig = ''
      # Server options
      header {
        -Server
        X-Cache-Status {http.reverse_proxy.cache.status}
      }

      encode {
        gzip {
          level 6
          min_length 256
        }
      }

      # File serving and compression
      root * ${cfg.package}/share/fireshare/client
      file_server
      try_files {path} /index.html

      # /_content/ location
      handle /_content/* {
        root * ${cfg.dataDir}/processed
        rewrite * /{path}
        file_server
        header Cache-Control "max-age=600" if {status} in 200 302
        header Cache-Control "max-age=60" if status 404
      }

      handle /_content/video/* {
        root * ${cfg.dataDir}/processed/video_links
        rewrite * /{path}
        file_server
      }

      handle /api/* {
        reverse_proxy http://${cfg.backendListenAddress} {
          header_up Host {http.request.host}
          transport http {
            dial_timeout 60s
          }
        }
      }

      handle /w/* {
        reverse_proxy http://${cfg.backendListenAddress} {
          header_up Host {http.request.host}
          transport http {
            dial_timeout 60s
            read_timeout 60s
          }
        }
      }

      # Redirect www to non-www (optional)
      @www {
        host ^www\.${lib.escapeRegex finalEnv.DOMAIN}$
      }
      redir @www https://${finalEnv.DOMAIN}{uri} permanent
    '';

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

      serviceConfig = {
        ExecStart = "${getExe' cfg.package "fireshare-cli"} init-db";
        ConditionFileNotEmpty = "!${finalEnv.DATA_DIRECTORY}/db.sqlite";
        StateDirectory = "${config.users.users.${cfg.user}.home}/.local/state";
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

      script = ''
        [[ -f "${cfg.dataDir}/jobs.sqlite" ]] && rm "${cfg.dataDir}/jobs.sqlite"

        ${getExe' cfg.package "fireshare-server"} \
          --bind="${cfg.backendListenAddress}" \
          ${lib.escapeShellArgs cfg.extraArgs}
      '';

      serviceConfig = {
        ConditionFileNotEmpty = "${finalEnv.DATA_DIRECTORY}/db.sqlite";
        StateDirectory = "${config.users.users.${cfg.user}.home}/.local/state";
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
