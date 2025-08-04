{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:

# TODO: maybe a proper module
let
  inherit (lib) recursiveUpdate;
  inherit (pkgs) formats;

  aikarsFlags =
    "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200"
    + " -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch"
    + " -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M"
    + " -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4"
    + " -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90"
    + " -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem"
    + " -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs"
    + " -Daikars.new.flags=true";

  mkServer =
    port: overrides:
    let
      default = {
        autoStart = true;
        jvmOpts = "-Xms20G -Xmx20G ${aikarsFlags}";

        serverProperties = {
          server-ip = "127.0.0.1";
          server-port = port;

          spawn-protection = 0;
          view-distance = 12;
          simulation-distance = 12;

          gamemode = "survival";
          difficulty = "hard";

          white-list = true;
        };

        operators.nanoyaki = "433b63b5-5f77-4a9f-b834-8463d520500c";

        whitelist = import ./whitelist.nix;

        symlinks = {
          "server-icon.png" = ./icon.png;

          "config/roles.json" = {
            format = formats.json { };
            value = {
              whitelister.overrides.commands."whitelist (add|remove)" = "allow";
              everyone.overrides.commands = {
                "image2map create" = "allow";
                "tick query" = "allow";
              };
            };
          };
        };

        files."config/FabricProxy-Lite.toml" = {
          format = formats.toml { };
          value = {
            hackOnlineMode = true;
            hackMessageChain = true;
            disconnectMessage = "Please connect through the proxy.";
            secret = "@FABRIC_PROXY_SECRET@";
          };
        };
      };
    in
    recursiveUpdate default overrides;

  mkVoiceChatCfg = port: {
    format = formats.keyValue { };
    value = {
      inherit port;
      bind_address = "";
      max_voice_distance = 64.0;
      crouch_distance_multiplier = 0.75;
      whisper_distance_multiplier = 0.5;
      codec = "VOIP";
      mtu_size = 1024;
      keep_alive = 1000;
      enable_groups = true;
      voice_host = "theless.one:${toString port}";
      allow_recording = true;
      spectator_interaction = false;
      spectator_player_possession = false;
      force_voice_chat = false;
      login_timeout = 10000;
      broadcast_range = -1.0;
      allow_pings = true;
    };
  };
in

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
    (import ./overlay.nix)
  ];

  sops.secrets.proxy.sopsFile = ./secrets.yaml;
  sops.secrets.bot-token.sopsFile = ./secrets.yaml;

  sops.templates."minecraft-secrets.env".file =
    (formats.keyValue { }).generate "minecraft-secrets.env"
      {
        DISCORDMCCHAT_BOT_TOKEN = config.sops.placeholder.bot-token;
        FABRIC_PROXY_SECRET = config.sops.placeholder.proxy;
      };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    environmentFile = config.sops.templates."minecraft-secrets.env".path;

    openFirewall = true;

    servers = {
      smp = mkServer 30050 {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_7;

        serverProperties = {
          # Joshs-more-foods
          require-resource-pack = true;
          resource-pack-prompt = ''
            The server requires this resource pack for the datapack joshs more foods.
            Using it does not mean you won't be able to use your own on top of it.
          '';
          resource-pack = "https://cdn.modrinth.com/data/3BlwZj8w/versions/bybBGRCd/joshs-more-foods_5.5.1_resource_pack.zip";
          resource-pack-sha1 = "0df9086d7918e03aed27fd4c2621177d7b81b31e";
        };

        files = {
          "config/discord-mc-chat.json" = {
            format = formats.json { };
            value = {
              generic = {
                language = "en_us";
                botToken = "@DISCORDMCCHAT_BOT_TOKEN@";
                channelId = "1395405287984201738";
                adminsIds = [
                  "1063583541641871440"
                  "222458973876387841"
                ];

                avatarApi = "https://visage.surgeplay.com/bust/{player_uuid}.png";
                broadcastPlayerCommandExecution = false;
                broadcastSlashCommandExecution = false;
                whitelistRequiresAdmin = false;
                announceHighMspt = false;
                excludedCommands = [ ".*" ];
              };
            };
          };

          "world/datapacks" = pkgs.datapackSet.default.override {
            gamerules = {
              locatorBar = false;
              disableElytraMovementCheck = true;
              disablePlayerMovementCheck = true;
              playersSleepingPercentage = 33;
            };
          };
        };

        symlinks = {
          mods = pkgs.fabricModpacks.smp;

          "config/voicechat/voicechat-server.properties" = mkVoiceChatCfg 24454;

          "config/bluemap/core.conf" = {
            format = formats.hocon { };
            value = {
              accept-download = true;
              scan-for-mod-resources = true;
              data = "bluemap";
              render-thread-count = 12;
              metrics = false;
              log.file = "logs/bluemap.log";
              log.append = true;
            };
          };

          "config/bluemap/plugin.conf" = {
            format = formats.hocon { };
            value = {
              live-player-markers = true;
              hidden-game-modes = [ "spectator" ];
              hide-vanished = true;
              hide-invisible = true;
              hide-sneaking = true;
              hide-below-sky-light = 0;
              hide-below-block-light = 0;
              hide-different-world = false;
              skin-download = true;
              player-render-limit = -1;
              full-update-interval = 720;
            };
          };

          "config/bluemap/webapp.conf" = {
            format = formats.hocon { };
            value = {
              enabled = true;
              webroot = "bluemap/web";
              update-settings-file = true;
              use-cookies = true;
              enable-free-flight = true;
              default-to-flat-view = false;
              min-zoom-distance = 5;
              max-zoom-distance = 100000;
              resolution-default = 1;

              hires-slider-max = 500;
              hires-slider-default = 100;
              hires-slider-min = 0;

              lowres-slider-max = 7000;
              lowres-slider-default = 2000;
              lowres-slider-min = 500;

              scripts = [ ];
              styles = [ ];
            };
          };

          "config/bluemap/webserver.conf" = {
            format = formats.hocon { };
            value = {
              enabled = true;
              webroot = "bluemap/web";
              port = 8100;

              log = {
                file = "logs/bluemap.log";
                append = true;
                format = "%1$s \"%3$s %4$s %5$s\" %6$s %7$s";
              };
            };
          };
        };
      };

      smp-creative = mkServer 30051 {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_7;
        jvmOpts = "-Xms8G -Xmx8G ${aikarsFlags}";

        serverProperties = {
          gamemode = "creative";
          difficulty = "normal";
          level-seed = "-7952476580899652458";
        };

        # TODO: use a proper permission system
        operators = import ./whitelist.nix;

        symlinks = {
          mods = pkgs.fabricModpacks.creative;

          "config/voicechat/voicechat-server.properties" = mkVoiceChatCfg 24455;
        };

        files."world/datapacks" = pkgs.datapackSet.default.override {
          gamerules = {
            keepInventory = true;
            doMobSpawning = false;
            mobGriefing = false;
            disableElytraMovementCheck = true;
            disablePlayerMovementCheck = true;
          };
        };
      };

      lobby = mkServer 30052 {
        enable = true;
        enableReload = true;
        package = pkgs.fabricServers.fabric-1_21_7;
        jvmOpts = "-Xms2G -Xmx2G ${aikarsFlags}";

        serverProperties = {
          gamemode = "adventure";
          difficulty = "normal";

          spawn-protection = 16;
          view-distance = 4;
          simulation-distance = 4;

          level-seed = "-7952476580899652458";
        };

        symlinks = {
          mods = pkgs.fabricModpacks.creative.override { without = [ pkgs.fabricMods.v1_21_7.axiom ]; };

          "config/voicechat/voicechat-server.properties" = mkVoiceChatCfg 24456;
        };

        files = {
          "world/datapacks/declarative_gamerules" = pkgs.datapackSet.gamerules {
            keepInventory = true;
            doMobSpawning = false;
            mobGriefing = false;
            disableElytraMovementCheck = true;
            disablePlayerMovementCheck = true;
            spawnRadius = 32;
          };

          "world/datapacks/killheal" = inputs.killheal.packages.x86_64-linux.killheal;
        };
      };

      proxy = {
        enable = true;
        autoStart = true;
        package = pkgs.velocityServers.velocity;
        jvmOpts = "-Xms1G -Xmx1G";

        symlinks."velocity.toml" = {
          format = formats.toml { };
          value = {
            config-version = "2.7";
            bind = "0.0.0.0:25565";
            motd =
              "<#dce0e8>T</#dce0e8><#8caaee>h</#8caaee><#dce0e8>e</#dce0e8>"
              + "<#8caaee>l</#8caaee><#dce0e8>e</#dce0e8><#8caaee>s</#8caaee><#dce0e8>s</#dce0e8>"
              + "<#8caaee>.</#8caaee><#dce0e8>o</#dce0e8><#8caaee>n</#8caaee><#dce0e8>e</#dce0e8>"
              + " <#8caaee>❄</#8caaee>";
            show-max-players = 50;
            online-mode = true;
            force-key-authentication = true;
            player-info-forwarding-mode = "MODERN";
            forwarding-secret-file = "forwarding.secret";
            kick-existing-players = true;
            ping-passthrough = "DISABLED";
            sample-players-in-ping = true;

            servers = {
              smp = "127.0.0.1:30050";
              creative = "127.0.0.1:30051";
              lobby = "127.0.0.1:30052";

              try = [
                "smp"
                "lobby"
              ];
            };

            forced-hosts = {
              "theless.one" = [ "smp" ];
              "creative.theless.one" = [ "creative" ];
              "lobby.theless.one" = [ "lobby" ];
            };

            query.enabled = false;
          };
        };

        files."forwarding.secret" = pkgs.writeText "forwarding.secret" "@FABRIC_PROXY_SECRET@";
      };
    };
  };

  # Simple voice chat
  networking.firewall.allowedUDPPorts = [
    24454
    24455
    24456
  ];
  config'.caddy.reverseProxies."map.theless.one".port = 8100;
}
