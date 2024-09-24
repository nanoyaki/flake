{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.lavalink;

  format = pkgs.formats.yaml { };
in
with lib;
{
  options.services.lavalink = {
    enable = mkEnableOption "Lavalink";

    package = mkOption {
      type = types.package;
      default = pkgs.lavalink;
      description = "The Lavalink package to use.";
    };

    password = mkOption {
      type = types.str;
      default = null;
      description = ''
        The password for Lavalink's authentication in plain text.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 2333;
      example = 4567;
      description = ''
        The port that Lavalink will use.
      '';
    };

    address = mkOption {
      type = types.str;
      default = "0.0.0.0";
      example = "127.0.0.1";
      description = ''
        The network address to bind to.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Whether to expose the port to the network.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "lavalink";
      example = "root";
      description = ''
        The user of the service.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "lavalink";
      example = "medias";
      description = ''
        The group of the service.
      '';
    };

    home = mkOption {
      type = types.str;
      default = "/var/lib/lavalink";
      example = "/home/lavalink";
      description = ''
        The home folder for lavalink.
      '';
    };

    enableHttp2 = mkEnableOption "HTTP/2 support";

    jvmArgs = mkOption {
      type = types.str;
      default = "-Xmx6G";
      example = "-Djava.io.tmpdir=/var/lib/lavalink/tmp -Xmx6G";
      description = ''
        Set custom JVM arguments.
      '';
    };

    plugins = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              example = "youtube";
              description = ''
                The name of the plugin to use for the plugin configuration.
              '';
            };

            dependency = mkOption {
              type = types.str;
              example = "dev.lavalink.youtube:youtube-plugin:1.8.0";
              description = ''
                The coordinates of the plugin.
              '';
            };

            repository = mkOption {
              type = types.str;
              example = "https://maven.example.com/releases";
              default = "https://maven.lavalink.dev/releases";
              description = ''
                The plugin repository. Defaults to the lavalink releases repository.
              '';
            };

            snapshot = mkOption {
              type = types.bool;
              default = false;
              example = true;
              description = ''
                Whether to use the snapshot repository instead of the release repository.
              '';
            };

            hash = mkOption {
              type = types.str;
              example = fakeSha256;
              description = ''
                The hash of the plugin.
              '';
            };

            extraConfig = mkOption {
              type = types.submodule { freeformType = format.type; };
              description = ''
                The configuration for the plugin.
              '';
            };
          };
        }
      );
      default = [ ];
      example = [
        {
          name = "youtube";
          dependency = "dev.lavalink.youtube:youtube-plugin:1.8.0";
          snapshot = false;
          extraConfig = {
            enabled = true;
            allowSearch = true;
            allowDirectVideoIds = true;
            allowDirectPlaylistIds = true;
          };
          hash = lib.fakeSha256;
        }
      ];
      description = ''
        A list of plugins for lavalink.
      '';
    };

    extraConfig = mkOption {
      type = types.submodule { freeformType = format.type; };
      description = ''
        Configuration to write to {file}`application.yml`.

        Individual configuration parameters can be overwritten using environment variables.
        See <https://lavalink.dev/configuration/index.html> for more information.
      '';
      default = {
        lavalink.server = {
          sources = {
            youtube = false;
            bandcamp = true;
            soundcloud = true;
            twitch = true;
            vimeo = true;
            nico = true;
            http = false;
            local = false;
          };

          filters = {
            volume = true;
            equalizer = true;
            karaoke = true;
            timescale = true;
            tremolo = true;
            distortion = true;
            rotation = true;
            channelMix = true;
            lowPass = true;
          };

          bufferDurationMs = 400;
          frameBufferDurationMs = 5000;
          opusEncodingQuality = 10;
          resamplingQuality = "LOW";
          trackStuckThresholdMs = 10000;
          useSeekGhosting = true;
          youtubePlaylistLoadLimit = 6;
          playerUpdateInterval = 5;
          youtubeSearchEnabled = true;
          soundcloudSearchEnabled = true;
          gc-warnings = true;
        };

        metrics.prometheus = {
          enabled = config.prometheus.enable;
          endpoint = "/metrics";
        };

        sentry = {
          dsn = "";
          environment = "";
        };

        logging = {
          file.path = "./logs/";

          level = {
            root = "INFO";
            lavalink = "INFO";
          };

          request = {
            enabled = true;
            includeClientInfo = true;
            includeHeaders = false;
            includeQueryString = true;
            includePayload = true;
            maxPayloadLength = 10000;
          };

          logback.rollingpolicy = {
            max-file-size = "1GB";
            max-history = 30;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    users.groups = mkIf (cfg.group == "lavalink") { lavalink = { }; };
    users.users = mkIf (cfg.user == "lavalink") {
      lavalink = {
        group = "lavalink";
        home = cfg.home;
        description = "The user for the Lavalink server";
        isSystemUser = true;
      };
    };

    systemd.tmpfiles.settings."10-lavalink" = {
      "${cfg.home}/plugins".d = {
        mode = "0700";
        user = cfg.user;
        group = cfg.group;
      };

      "${cfg.home}/".d = {
        mode = "0700";
        user = cfg.user;
        group = cfg.group;
      };
    };

    systemd.services.lavalink = {
      description = "Lavalink Service";

      wantedBy = [ "multi-user.target" ];
      after = [
        "syslog.target"
        "network.target"
      ];

      script =
        let
          pluginLinks = concatStringsSep "\n" (
            forEach cfg.plugins (
              pluginConfig:
              let
                pluginInParts = match "^(.*?:(.*?):)(d+.d+.d+)$" pluginConfig.dependency;
                pluginPath = (
                  replaceStrings
                    [
                      "."
                      ":"
                    ]
                    [
                      "/"
                      "/"
                    ]
                    (elemAt pluginInParts 0)
                );
                pluginFileName = elemAt pluginInParts 1;
                pluginVersion = elemAt pluginInParts 2;
                plugin = pkgs.fetchurl {
                  url = concatStrings [
                    pluginConfig.repository
                    "/"
                    pluginPath
                    pluginVersion
                    "/"
                    pluginFileName
                    "-"
                    pluginVersion
                    ".jar"
                  ];
                  hash = pluginConfig.hash;
                };
              in
              "ln -s ${plugin.outPath} plugins/${baseNameOf plugin}"
            )
          );
          configFile = format.generate "application.yml" (mkMerge [
            (mkForce {
              server = {
                port = cfg.port;
                address = cfg.address;
                http2.enabled = cfg.enableHttp2;
              };
              plugins = mapAttrs' (
                index: pluginConfig: nameValuePair (pluginConfig.name) (pluginConfig.extraConfig)
              ) cfg.plugins;
              lavalink.plugins = forEach (
                pluginConfig:
                removeAttrs pluginConfig [
                  "name"
                  "extraConfig"
                  "hash"
                ]
              ) cfg.plugins;
            })
            cfg.extraConfig
          ]);
        in
        ''
          ${pluginLinks}
          echo "${configFile}" > ${cfg.home}/application.yml
          export _JAVA_OPTIONS="${cfg.jvmArgs}"
          ${getExe cfg.package} -Xmx6G
        '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        Type = "simple";
        Restart = "on-failure";

        WorkingDirectory = "/var/lib/lavalink";
      };
    };
  };
}
