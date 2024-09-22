{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.lavalink;

  format = pkgs.formats.yaml {};
  plugins =
    if cfg.enableYouTube
    then [
      {
        name = "youtube";
        dependency = "dev.lavalink.youtube:youtube-plugin:1.8.0";
        snapshot = false;
      }
    ]
    else [] ++ cfg.plugins;
  configFile = format.generate "application.yml" (lib.mkMerge [
    (lib.mkForce {
      server = {
        port = cfg.port;
        address = cfg.address;
        http2.enabled = cfg.enableHttp2;
      };
      plugins = lib.mapAttrs' (index: pluginConfig: lib.nameValuePair (pluginConfig.name) (pluginConfig.extraConfig)) plugins;
      lavalink.plugins = lib.forEach (pluginConfig: lib.removeAttrs pluginConfig ["name" "extraConfig" "hash"]) plugins;
    })
    cfg.extraConfig
  ]);
in
  with lib; {
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

      enableHttp2 = mkEnableOption "HTTP/2 support";

      enableYouTube = mkEnableOption ''
        the YouTube plugin.
        This is the recommended way to use YouTube as a source
      '';

      jvmArgs = mkOption {
        type = types.str;
        default = "-Xmx6G";
        example = "-Djava.io.tmpdir=/var/lib/lavalink/tmp -Xmx6G";
        description = ''
          Set custom JVM arguments.
        '';
      };

      plugins = mkOption {
        type = types.listOf (types.submodule {
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

          extraConfig = mkOption {
            type = types.submodule {
              freeformType = format.type;
            };
            description = ''
              The configuration for the plugin.
            '';
          };

          hash = mkOption {
            type = types.str;
            example = fakeSha256;
            description = ''
              The hash of the plugin.
            '';
          };
        });
        default = [];
        example = [
          {
            name = "youtube";
            dependency = "dev.lavalink.youtube:youtube-plugin:1.8.0";
            snapshot = false;
            extraConfig = {};
            hash = lib.fakeSha256;
          }
        ];
        description = ''
          A list of plugins for lavalink.
        '';
      };

      extraConfig = mkOption {
        type = types.submodule {
          freeformType = format.type;
        };
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
      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];

      users.groups.lavalink = {};
      users.users.lavalink = {
        group = "lavalink";
        home = "/var/lib/lavalink";
        description = "The user for the Lavalink server";
        isSystemUser = true;
      };

      systemd.tmpfiles.settings."10-lavalink" = {
        "/var/lib/lavalink/".d = {
          mode = "0700";
          user = "lavalink";
          group = "lavalink";
        };
      };

      systemd.services.lavalink = {
        description = "Lavalink Service";

        wantedBy = ["multi-user.target"];
        after = ["syslog.target" "network.target"];

        script = ''
          echo "${configFile}" > /var/lib/lavalink/application.yml
          export _JAVA_OPTIONS="${cfg.jvmArgs}"
          ${getExe cfg.package} -Xmx6G
        '';

        serviceConfig = {
          User = "lavalink";
          Group = "lavalink";

          Type = "simple";
          Restart = "on-failure";

          WorkingDirectory = "/var/lib/lavalink";
        };
      };
    };
  }
