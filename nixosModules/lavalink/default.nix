{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.lavalink;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;

  format = pkgs.formats.yaml { };
in

{
  options.services.lavalink = {
    enable = mkEnableOption "Lavalink";

    package = lib.mkPackageOption pkgs "lavalink" { };

    password = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "s3cRe!p4SsW0rD";
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
      default = "-Xmx4G";
      example = "-Djava.io.tmpdir=/var/lib/lavalink/tmp -Xmx6G";
      description = ''
        Set custom JVM arguments.
      '';
    };

    plugins = mkOption {
      type = types.listOf (types.submodule (import ./plugins.nix { inherit lib pkgs; }));
      default = [ ];

      example = lib.literalExpression ''
        [
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
            hash = lib.fakeHash;
          }
        ]
      '';

      description = ''
        A list of plugins for lavalink.
      '';
    };

    extraConfig = mkOption {
      type = types.submodule { freeformType = format.type; };

      description = ''
        Configuration to write to {file}`application.yml`.
        See <https://lavalink.dev/configuration/#example-applicationyml> for the full documentation.

        Individual configuration parameters can be overwritten using environment variables.
        See <https://lavalink.dev/configuration/#example-environment-variables> for more information.
      '';

      default = { };

      example = lib.literalExpression ''
        {
          lavalink.server = {
            sources.twitch = true;

            filters.volume = true;
          };

          logging.file.path = "./logs/";
        }
      '';
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

    systemd.tmpfiles.settings."10-lavalink" =
      let
        dirConfig = {
          mode = "0700";
          user = cfg.user;
          group = cfg.group;
        };
      in
      {
        "${cfg.home}/plugins".d = dirConfig;
        "${cfg.home}/".d = dirConfig;
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
          pluginLinks = lib.concatStringsSep "\n" (
            map (
              pluginConfig:
              let
                pluginParts = lib.match ''^(.*?:(.*?):)([0-9]+\.[0-9]+\.[0-9]+)$'' pluginConfig.dependency;

                pluginWebPath = (
                  lib.replaceStrings
                    [
                      "."
                      ":"
                    ]
                    [
                      "/"
                      "/"
                    ]
                    (lib.elemAt pluginParts 0)
                );

                pluginFileName = lib.elemAt pluginParts 1;
                pluginVersion = lib.elemAt pluginParts 2;

                pluginJarFile = "${pluginFileName}-${pluginVersion}.jar";
                pluginUrl = "${pluginConfig.repository}/${pluginWebPath}${pluginVersion}/${pluginJarFile}";

                plugin = pkgs.fetchurl {
                  url = pluginUrl;
                  hash = pluginConfig.hash;
                };
              in
              "ln -sf ${plugin} plugins/${pluginJarFile}"
            ) cfg.plugins
          );

          configFilePlugins = lib.map (
            pluginConfig:
            builtins.removeAttrs pluginConfig [
              "name"
              "extraConfig"
              "hash"
            ]
          ) cfg.plugins;

          pluginExtraConfigs = lib.listToAttrs (
            lib.map (pluginConfig: lib.nameValuePair pluginConfig.name pluginConfig.extraConfig) (
              lib.filter (x: x.name != null) cfg.plugins
            )
          );

          config = lib.recursiveUpdate cfg.extraConfig {
            server = {
              port = cfg.port;
              address = cfg.address;
              http2.enabled = cfg.enableHttp2;
            };
            plugins = pluginExtraConfigs;
            lavalink.plugins = configFilePlugins;
          };

          configWithPassword = lib.recursiveUpdate config (
            lib.optionalAttrs (cfg.password != null) { lavalink.server.password = cfg.password; }
          );

          configFile = format.generate "application.yml" configWithPassword;
        in
        ''
          ${pluginLinks}

          ln -sf ${configFile} ${cfg.home}/application.yml
          export _JAVA_OPTIONS="${cfg.jvmArgs}"

          ${lib.getExe cfg.package}
        '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        Type = "simple";
        Restart = "on-failure";

        WorkingDirectory = cfg.home;
      };
    };
  };
}