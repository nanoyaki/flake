{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:

let
  aikarsFlags = "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";

  defaults = {
    autoStart = true;
    jvmOpts = "-Xms20G -Xmx20G ${aikarsFlags}";

    serverProperties = {
      server-ip = "127.0.0.1";

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

    files."config/FabricProxy-Lite.toml" = writeTOML "FabricProxy-Lite.toml" {
      hackOnlineMode = true;
      hackMessageChain = true;
      disconnectMessage = "Please connect through the proxy.";
      secret = "@FABRIC_PROXY_SECRET@";
    };
  };

  writeJSON = (pkgs.formats.json { }).generate;
  writeHocon = (pkgs.formats.hocon { }).generate;
  writeKeyValue = (pkgs.formats.keyValue { }).generate;
  writeTOML = (pkgs.formats.toml { }).generate;
in

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
    (final: _: {
      fabricMods.default = final.callPackage ./mods.nix { };
    })
  ];

  sops.secrets.proxy.sopsFile = ./secrets.yaml;
  sops.secrets.bot-token.sopsFile = ./secrets.yaml;

  sops.templates."minecraft-secrets.env".file = writeKeyValue "proxy-secrets.env" {
    DISCORDMCCHAT_BOT_TOKEN = config.sops.placeholder.bot-token;
    FABRIC_PROXY_SECRET = config.sops.placeholder.proxy;
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    environmentFile = config.sops.templates."minecraft-secrets.env".path;

    openFirewall = true;

    servers = {
      smp = lib.recursiveUpdate defaults {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_7;

        serverProperties.server-port = 30050;

        files."config/discord-mc-chat.json" = writeJSON "discord-mc-chat.json" {
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
              DiscordMcChat = {
                sha512 = "5d653d21048cea1eeaff13bf1f63619133384385b4da21c5105c64e4b1b6ac67c04fd8534768d0a5125a9c940a4dc38ce64cba6b202e86e705a5ef9b45a8c4d5";
                url = "https://cdn.modrinth.com/data/D0sHdnXY/versions/PtVawIb0/Discord-MC-Chat-2.5.0.jar";
              };
              DistantHorizons = {
                sha512 = "5f8d4e564f65dcbe5e039af8605da4df8a8edcc2218a46aad827aaa8d1e8848adb302672735f579715be1c480956dd6dd7548a2bff9bacc4f0ef0592eeceb238";
                url = "https://cdn.modrinth.com/data/uCdwusMi/versions/2mY04ehi/DistantHorizons-2.3.3-b-1.21.7-fabric-neoforge.jar";
              };
            };
          };

          "config/voicechat/voicechat-server.properties" = writeKeyValue "voicechat-server.properties" {
            port = 24454;
            bind_address = "";
            max_voice_distance = 64.0;
            crouch_distance_multiplier = 0.75;
            whisper_distance_multiplier = 0.5;
            codec = "VOIP";
            mtu_size = 1024;
            keep_alive = 1000;
            enable_groups = true;
            voice_host = "";
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
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_7;
        jvmOpts = "-Xms8G -Xmx8G ${aikarsFlags}";

        serverProperties = {
          gamemode = "creative";

          server-port = 30051;
          level-seed = "-7952476580899652458";
        };

        operators = import ./whitelist.nix;

        symlinks.mods = pkgs.fabricMods.default.override {
          additionalMods.Axiom = {
            sha512 = "4aafc025ad5e652060f7cff74dade9fcc6ec770a5f310fe970eedd6f6c7154c6cc10a33e0fbe9c648bed736b552ea645c530ce92f371acbcd6c93a6f313ca4b5";
            url = "https://cdn.modrinth.com/data/N6n5dqoA/versions/CRjwbqnJ/Axiom-4.9.1-for-MC1.21.6.jar";
          };
          without = [
            "SimpleVoiceChat"
          ];
        };
      };

      proxy = {
        enable = true;
        autoStart = true;
        package = pkgs.velocityServers.velocity;
        jvmOpts = "-Xms1G -Xmx1G";

        symlinks."velocity.toml" = writeTOML "velocity.toml" {
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

            try = [ "smp" ];
          };

          forced-hosts."theless.one" = [ "smp" ];
          forced-hosts."creative.theless.one" = [ "creative" ];

          query.enabled = false;
        };

        files."forwarding.secret" = pkgs.writeText "forwarding.secret" "@FABRIC_PROXY_SECRET@";
      };
    };
  };

  config'.caddy.reverseProxies."map.theless.one".port = 8100;
}
