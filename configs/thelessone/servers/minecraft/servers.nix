{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:

let
  defaults = {
    autoStart = true;
    jvmOpts = "-Xms32G -Xmx32G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";

    serverProperties = {
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

      "config/roles.json" = writeJSON "roles.json" {
        whitelister.overrides.commands."whitelist (add|remove)" = "allow";
        everyone.overrides.commands = {
          "image2map create" = "allow";
          "tick query" = "allow";
        };
      };
    };
  };

  writeJSON = (pkgs.formats.json { }).generate;
  writeHocon = (pkgs.formats.hocon { }).generate;
in

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
    (final: _: {
      fabricMods.default = final.callPackage ./mods.nix { };
    })
  ];

  sec."minecraft/botToken" = { };

  sops.templates."discord-mc-chat.json" = {
    file = writeJSON "discord-mc-chat.json" {
      generic = {
        language = "en_us";
        botToken = config.sops.placeholder."minecraft/botToken";
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
    path = "${config.services.minecraft-servers.dataDir}/smp/config/discord-mc-chat.json";
    owner = config.services.minecraft-servers.user;
    restartUnits = [ "minecraft-server-smp.service" ];
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;

    openFirewall = true;

    servers = {
      smp = lib.recursiveUpdate defaults {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_7;

        serverProperties.server-port = 25565;

        symlinks = {
          mods = pkgs.fabricMods.default.override {
            additionalMods = {
              Bluemap = {
                sha512 = "a76a2b1019efe35175f8df91f69ec7ec58e26f148ea9bba4f1eb9bb1b16ffa6f395b76c1362f452d33f94f0f1045403da3b04f25bc6d40feadbc58f64d34f1e4";
                url = "https://cdn.modrinth.com/data/swbUV1cr/versions/fB6f4XRA/bluemap-5.9-fabric.jar";
              };
              BluemapSignMarkers = {
                sha512 = "d3efb15a03ef3dcc02bcd2395c578afdc2d413d5e4dfcf65c9cad891e755ade9d6a7961e7b0f07e7e229b831d11d6459efdb5a935d0e5597c1782ec9ca8e2b41";
                url = "https://cdn.modrinth.com/data/i5ZtmNIW/versions/vCOKmCcE/bluemapsignmarkers-1.21.7-0.11.0.56.jar";
              };
              DistantHorizons = {
                sha512 = "5f8d4e564f65dcbe5e039af8605da4df8a8edcc2218a46aad827aaa8d1e8848adb302672735f579715be1c480956dd6dd7548a2bff9bacc4f0ef0592eeceb238";
                url = "https://cdn.modrinth.com/data/uCdwusMi/versions/2mY04ehi/DistantHorizons-2.3.3-b-1.21.7-fabric-neoforge.jar";
              };
            };
          };

          "config/voicechat/voicechat-server.properties" =
            (pkgs.formats.keyValue { }).generate "voicechat-server.properties"
              {
                port = 24454;
                bind_address = "";
                max_voice_distance = 64.0;
                crouch_distance_multiplier = 0.75;
                whisper_distance_multiplier = 0.5;
                codec = "VOIP";
                mtu_size = 1024;
                keep_alive = 1000;
                enable_groups = true;
                voice_host = "theless.one:24454";
                allow_recording = true;
                spectator_interaction = false;
                spectator_player_possession = false;
                force_voice_chat = false;
                login_timeout = 10000;
                broadcast_range = -1.0;
                allow_pings = true;
              };

          "config/bluemap/core.conf" = writeHocon "core.conf" {
            accept-download = true;
            scan-for-mod-resources = true;
            data = "bluemap";
            render-thread-count = 12;
            metrics = false;
            log.file = "logs/bluemap.log";
            log.append = true;
          };

          "config/bluemap/plugin.conf" = writeHocon "plugin.conf" {
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

          "config/bluemap/webapp.conf" = writeHocon "webapp.conf" {
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

          "config/bluemap/webserver.conf" = writeHocon "webserver.conf" {
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

      smp-creative = lib.recursiveUpdate defaults {
        serverProperties = {
          gamemode = "creative";

          server-port = 25566;
          level-seed = "-7952476580899652458";
        };

        symlinks.mods = pkgs.fabricMods.default.override {
          without = [
            "DistantHorizons"
            "SimpleVoiceChat"
          ];
        };
      };
    };
  };

  services.caddy.package = pkgs.caddy.withPlugins {
    plugins = [ "github.com/mholt/caddy-l4@v0.0.0-20250530154005-4d3c80e89c5f" ];
    hash = "sha256-O2shDuAA4OjUx44uOxMbd5iQUQVl6GUuFKqv+P/PXNM=";
  };
  # services.caddy.globalConfig = ''
  #   layer4 {
  #     creative.theless.one {
  #       route {
  #         proxy localhost:25566
  #       }
  #     }
  #   }
  # '';

  services'.caddy.reverseProxies."map.theless.one".port = 8100;
}
